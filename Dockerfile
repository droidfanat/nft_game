FROM node:15.13.0-buster


WORKDIR /app
COPY package.json /app/package.json
ADD . /app
RUN npm install -g truffle && npm install -g ganache-cli && npm install 
