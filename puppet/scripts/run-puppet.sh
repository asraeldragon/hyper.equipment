#!/bin/bash
set -euo pipefail
REPO_ROOT="$(git -C "$(dirname -- "$( readlink -f -- "${0}"; )")" rev-parse --show-toplevel)"
PUPPET_DISABLEFILE="/puppet-disabled"
cd "$REPO_ROOT"

# Since we can't use puppet agent --disable, have a custom lock
if [ -f "$PUPPET_DISABLEFILE" ]; then
  echo "Puppet run disabled, reason:"
  cat "$PUPPET_DISABLEFILE"
  exit 0
fi

# Update Git repo
git fetch origin
git reset --hard origin/master
git submodule update --init --recursive

# Install modules
r10k puppetfile install \
  --puppetfile="${REPO_ROOT}/puppet/Puppetfile" \
  --moduledir=/etc/puppetlabs/code/modules

# Run Puppet
/opt/puppetlabs/bin/puppet apply \
  --config "${REPO_ROOT}/puppet/puppet.conf" \
  --hiera_config "${REPO_ROOT}/puppet/hiera.yaml" \
  --modulepath "/etc/puppetlabs/code/modules:${REPO_ROOT}/puppet/site" \
  "${REPO_ROOT}/puppet/site.pp" "$@"
