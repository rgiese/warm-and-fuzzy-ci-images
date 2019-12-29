FROM node:12.14-stretch

RUN apt-get update && \
    apt-get -y install make cmake gcc g++