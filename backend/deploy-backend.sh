#!/bin/bash
# Retrieve the task definition from ECS
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_NAME_BE" --region "$REGION")

# Register a new task definition with an updated image
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$IMAGE_NAME_BE" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_REVISION=$(aws ecs register-task-definition --region "$REGION" --cli-input-json "$NEW_TASK_DEFINITION")
echo $NEW_REVISION | jq '.taskDefinition.revision'


# Extract the task definition ARN, container name, and container port using jq
AWS_TASK_DEFINITION_ARN=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.taskDefinitionArn')
CONTAINER_NAME=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.containerDefinitions[0].name')
CONTAINER_PORT=$(echo $TASK_DEFINITION | jq -r '.taskDefinition.containerDefinitions[0].portMappings[0].containerPort')

# Create the application specification (AppSpec) in JSON format
APP_SPEC=$(jq -n --arg taskDef "$AWS_TASK_DEFINITION_ARN" --arg containerName "$CONTAINER_NAME" --argjson containerPort "$CONTAINER_PORT" '{
  version: "0.0",
  Resources: [
    {
      TargetService: {
        Type: "AWS::ECS::Service",
        Properties: {
          TaskDefinition: $taskDef,
          LoadBalancerInfo: {
            ContainerName: $containerName,
            ContainerPort: $containerPort
          }
        }
      }
    }
  ]
}')

# Create the revision configuration for the deployment
REVISION=$(jq -n --arg appSpec "$APP_SPEC" '{
  revisionType: "AppSpecContent",
  appSpecContent: {
    content: $appSpec
  }
}')

# Trigger the deployment using the specified application name, deployment group, and revision
aws deploy create-deployment --region "$REGION" \
  --application-name "$AWS_APPLICATION_NAME" \
  --deployment-group-name "$AWS_DEPLOYMENT_GROUP_NAME" \
  --revision "$REVISION"