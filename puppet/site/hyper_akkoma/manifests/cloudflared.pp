class hyper_akkoma::cloudflared {
  # ufw_rule { 'allow https':
  #   ensure => present,
  #   action => 'allow',
  #   direction => 'in',
  #   to_ports_app => 'https',
  # }

  apt::source { 'cloudflare':
    location      => 'https://pkg.cloudflare.com/cloudflared',
    notify_update => true,
    repos         => 'main',
    key           => {
      'id' => '254B391D8CACCBF8',
      'source' => 'https://pkg.cloudflare.com/cloudflare-main.gpg',
    },
  }

  package { 'cloudflared':
    ensure => installed,
  }

  # This module doesn't install the service, since it needs a secret key and I don't have encryption configured.
  # Not that I'd feel great about putting an encrypted value up in a semi public repo anyway.
  # Might add more here later.
}
