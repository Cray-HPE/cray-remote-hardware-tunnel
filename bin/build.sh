#!/usr/bin/env bash
set -ex

sudo ${container_cli} build . -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest
