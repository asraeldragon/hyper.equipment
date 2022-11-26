#!/bin/bash
set -euo pipefail
REPO_ROOT="$(dirname -- "$(dirname -- "$( readlink -f -- "${0}"; )")")"
cd "$REPO_ROOT"

# Update Git repo
git fetch origin
git reset --hard origin/master

# Install modules
r10k puppetfile install \
  --puppetfile="${REPO_ROOT}/puppet/Puppetfile" \
  --moduledir=/etc/puppetlabs/code/modules

# Run Puppet
/opt/puppetlabs/bin/puppet apply \
  --config "${REPO_ROOT}/puppet/puppet.conf" \
  --modulepath "/etc/puppetlabs/code/modules:${REPO_ROOT}/puppet/site" \
  "${REPO_ROOT}/puppet/site.pp"
