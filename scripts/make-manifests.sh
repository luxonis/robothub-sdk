#!/bin/bash
set -Eeux

BASE_AMD64_TAG="ghcr.io/luxonis/${IMAGE_REF_NAME}-amd64:${IMAGE_VERSION}"
BASE_ARM64_TAG="ghcr.io/luxonis/${IMAGE_REF_NAME}-arm64:${IMAGE_VERSION}"
BASE_TAG="ghcr.io/luxonis/${IMAGE_REF_NAME}:${IMAGE_VERSION}"

# Define suffixes
declare -a suffixes=(
    "core"
    "rvc2-minimal"
    "rvc2-regular"
    "rvc2-minimal-ros2humble"
    "rvc2-regular-ros2humble"
    "rvc3-minimal"
    "rvc3-regular"
    "rvc3-minimal-ros2humble"
    "rvc3-regular-ros2humble"
    "rvc2-builtin-app"
    "rvc3-builtin-app"
    "rae-provisioning-app"
)

# Make manifests
for suffix in "${suffixes[@]}"; do
    TAG="${BASE_TAG}-${suffix}"
    docker buildx imagetools create \
        --tag "${TAG}" \
        "${BASE_AMD64_TAG}-${suffix}" \
        "${BASE_ARM64_TAG}-${suffix}"
    DESCRIPTION=$(docker buildx imagetools inspect ${BASE_AMD64_TAG}-${suffix} --format '{{ index .Image.Config.Labels "org.opencontainers.image.description"}}')
    regctl image mod ${TAG} --create ${TAG} --annotation "org.opencontainers.image.description=$DESCRIPTION"
done
