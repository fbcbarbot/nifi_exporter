FROM golang:1.14 as builder
RUN mkdir /exporter
COPY . /exporter
WORKDIR /exporter

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /exporter/exporter main.go

FROM openjdk:8-jre

ARG NIFI_VERSION=1.11.4
ARG BASE_URL=https://archive.apache.org/dist
ARG MIRROR_BASE_URL=${MIRROR_BASE_URL:-${BASE_URL}}
ARG NIFI_TOOLKIT_BINARY_PATH=${NIFI_TOOLKIT_BINARY_PATH:-/nifi/${NIFI_VERSION}/nifi-toolkit-${NIFI_VERSION}-bin.zip}

ENV NIFI_BASE_DIR=/opt/nifi
ENV NIFI_TOOLKIT_HOME ${NIFI_BASE_DIR}/nifi-toolkit-current
ENV NIFI_EXPORTER_HOME ${NIFI_BASE_DIR}/exporter

RUN mkdir -p ${NIFI_EXPORTER_HOME}

# Download, validate, and expand Apache NiFi Toolkit binary.
RUN curl -fSL ${MIRROR_BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH} -o ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
    && echo "$(curl ${BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH}.sha256) *${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip" | sha256sum -c - \
    && unzip ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip -d ${NIFI_BASE_DIR} \
    && rm ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
    && mv ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION} ${NIFI_TOOLKIT_HOME} \
    && ln -s ${NIFI_TOOLKIT_HOME} ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}

COPY --from=builder /exporter/exporter ${NIFI_EXPORTER_HOME}
