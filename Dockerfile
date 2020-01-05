# Use Node LTS for now (be boring)
FROM node:12.14-buster

RUN apt-get update
RUN apt-get install -y apt-utils

#
# Python 3.x
#

RUN apt-get install -y python3-pip python3-dev

RUN \
  cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip


#
# AWS CLI
#

RUN pip3 install awscli


#
# C++ toolchain
#

RUN apt-get install -y git make cmake gcc g++

ENV GRUMPYCORP_ROOT /usr/grumpycorp


#
# Flatbuffers
#

ENV FLATBUFFERS_RELEASE v1.11.0

# Clone flatbuffers source
WORKDIR ${GRUMPYCORP_ROOT}
RUN git clone https://github.com/google/flatbuffers.git --branch ${FLATBUFFERS_RELEASE}

# Build flatbuffers tooling
WORKDIR ${GRUMPYCORP_ROOT}/flatbuffers
RUN cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
RUN make
RUN ./flattests


#
# Android toolchain
# (hat tip to https://github.com/thyrlian/AndroidSDK)
#

# Install essential tools
# Install Java
# Install Qt
RUN apt-get install -y --no-install-recommends \
      lib32gcc1 lib32ncurses5 lib32z1  \
      wget unzip \
      openjdk-8-jdk \
      qt5-default

# Download and install Gradle
# https://services.gradle.org/distributions/
ARG GRADLE_VERSION=5.6.4
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# Download and install Android SDK
# https://developer.android.com/studio/#downloads
ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# Set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

# Accept the license agreements of the SDK components
ADD android/license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_HOME