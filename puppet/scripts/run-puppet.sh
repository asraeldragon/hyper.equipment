#!/bin/bash
set -euo pipefail
REPO_ROOT="$(dirname -- "$(dirname -- "$( readlink -f -- "${0}"; )")")"
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

# Install modules
r10k puppetfile install \
  --puppetfile="${REPO_ROOT}/Puppetfile" \
  --moduledir=/etc/puppetlabs/code/modules

# Run Puppet
/opt/puppetlabs/bin/puppet apply \
  --config "${REPO_ROOT}/puppet/puppet.conf" \
  --hiera_config "${REPO_ROOT}/puppet/hiera.yaml" \
  --modulepath "/etc/puppetlabs/code/modules:${REPO_ROOT}/site" \
  "${REPO_ROOT}/site.pp" "$@"
