FROM node:12-alpine

RUN apk add --no-cache curl

WORKDIR /app

ADD package.json /app/package.json
RUN node -e "const {devDependencies,peerDependencies,...pkg} = require('./package.json'); require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2))"
RUN npm install --only=prod

ADD dist/ /app/dist/

ENV NODE_ENV "production"

ENTRYPOINT ["npm", "start"]
