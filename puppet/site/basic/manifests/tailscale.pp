class basic::tailscale {
  # not used. I set this file up then reconsidered.
  apt::source { 'tailscale':
    location      => 'https://pkgs.tailscale.com/stable/ubuntu',
    notify_update => true,
    repos         => 'main',
    key           => {
      'source' => 'https://pkgs.tailscale.com/stable/ubuntu/focal.gpg',
    },
  }

  package { 'tailscale':
    ensure => latest,
    notify => Exec['tailscale-up'],
  }

  exec { 'tailscale-up':
    refreshonly => true,
    path => '/usr/bin:/usr/local/bin:/bin:/sbin:/usr/sbin:/usr/local/sbin',
    command => 'tailscale up',
  }
}
