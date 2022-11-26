class hyper_akkoma::cloudflared {
  # ufw_rule { 'allow https':
  #   ensure => present,
  #   action => 'allow',
  #   direction => 'in',
  #   to_ports_app => 'https',
  # }

  package { 'cloudflared':
    * => $facts['os']['family'] ? {
      'RedHat' => {
        ensure   => installed,
        source   => 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm',
        provider => 'rpm',
      },
      'Debian' => {
        ensure   => installed,
        source   => 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb',
        provider => 'dpkg',
      },
      default  => {
        ensure   => installed,
      }
    }
  }

  # This module doesn't install the service, since it needs a secret key and I don't have encryption configured.
  # Not that I'd feel great about putting an encrypted value up in a semi public repo anyway.
  # Might add more here later.
}
