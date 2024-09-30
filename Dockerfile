FROM node:alpine

ENV APP_ROOT=/app

RUN mkdir ${APP_ROOT}

WORKDIR ${APP_ROOT}

ADD . ${APP_ROOT}

RUN npm install -g typescript

RUN npm install

RUN npm run build