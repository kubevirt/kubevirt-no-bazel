#!/usr/bin/env bash

set -ex

source hack/common.sh
source hack/config.sh

# bazeldnf comes from the builder image. MODULE.bazel also pins it for the
# Bazel build, so make sure both use the same version.
module_version=v$(sed -n 's/^bazel_dep(name = "bazeldnf", version = "\([^"]*\)")/\1/p' MODULE.bazel)
for dockerfile in hack/builder/Dockerfile hack/builder/Dockerfile.cs10; do
    builder_version=$(sed -n 's/^ENV BAZELDNF_VERSION=//p' "${dockerfile}")
    if [ "${builder_version}" != "${module_version}" ]; then
        echo "ERROR: ${dockerfile} installs bazeldnf ${builder_version}, but MODULE.bazel uses ${module_version}." >&2
        exit 1
    fi
done

# verify that RPMs with given digests in rpms.json
# are signed with known GPG keys in repo-cs9.yaml and repo-cs10.yaml
bazeldnf verify \
    --lockfile "rpms.json" \
    --repofile "rpm/repo-cs9.yaml" \
    --repofile "rpm/repo-cs10.yaml"
