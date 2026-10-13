#!/usr/bin/env bash

set -ex

source hack/common.sh
source hack/config.sh

# bazeldnf comes from the builder image. WORKSPACE still pins it for the
# Bazel build, so make sure both use the same version.
workspace_version=$(sed -n 's/.*strip_prefix = "bazeldnf-\(v[^"]*\)".*/\1/p' WORKSPACE)
for dockerfile in hack/builder/Dockerfile hack/builder/Dockerfile.cs10; do
    builder_version=$(sed -n 's/^ENV BAZELDNF_VERSION=//p' "${dockerfile}")
    if [ "${builder_version}" != "${workspace_version}" ]; then
        echo "ERROR: ${dockerfile} installs bazeldnf ${builder_version}, but WORKSPACE uses ${workspace_version}." >&2
        exit 1
    fi
done

# verify that RPMs with given SHASUMs in WORKSPACE files
# are signed with known GPG keys in repo.yaml
bazeldnf verify \
    --repofile "rpm/repo.yaml"
