FROM node:12-alpine

WORKDIR /app

ADD package.json /app/package.json
RUN npm install

ADD scripts/*.js /app/scripts/
ADD migrations/*.js /app/migrations/
ADD ormconfig.js /app/ormconfig.js

ENV NODE_ENV "production"