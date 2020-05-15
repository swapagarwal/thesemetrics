FROM node:12-alpine

WORKDIR /app

ADD package.json /app/package.json
RUN npm install

ADD migrations/*.js /app/migrations/
