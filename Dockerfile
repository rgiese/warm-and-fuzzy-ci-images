# Use Node LTS for now (be boring)
FROM node:12.14-stretch

# Install C++ toolchain
RUN apt-get update && \
    apt-get -y install git make cmake gcc g++

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