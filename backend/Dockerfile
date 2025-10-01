FROM node:20.18.0-alpine3.20
RUN apk add --no-cache bash
WORKDIR "/app"
COPY ./package.json ./
RUN npm install
COPY . .
CMD ["npm","run","dev"]