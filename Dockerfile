# Use Node LTS for now (be boring)
FROM node:12.14-stretch

RUN apt-get update
RUN apt-get install -y apt-utils

# Install C++ toolchain
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

# support multiarch: i386 architecture
#RUN dpkg --add-architecture i386
# libncurses5:i386 libc6:i386 libstdc++6:i386 zlib1g:i386

# install Java
# install essential tools
# install Qt
RUN apt-get install -y --no-install-recommends \
      lib32gcc1 lib32ncurses5 lib32z1  \
      openjdk-8-jdk \
      wget unzip \
      qt5-default

# download and install Gradle
# https://services.gradle.org/distributions/
ARG GRADLE_VERSION=5.6.4
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# download and install Android SDK
# https://developer.android.com/studio/#downloads
ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip *tools*linux*.zip && \
    rm *tools*linux*.zip

# set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

# WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
#ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

# accept the license agreements of the SDK components
ADD android/license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_HOME