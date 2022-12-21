class basic::tailscale {
  # not used. I set this file up then reconsidered.
  apt::source { 'tailscale':
    location      => 'https://pkgs.tailscale.com/stable/ubuntu',
    notify_update => true,
    repos         => 'main',
    key           => {
      'id' => '458CA832957F5868',
      'source' => 'https://pkgs.tailscale.com/stable/ubuntu/focal.gpg',
    },
  }

  package { 'tailscale':
    ensure => latest,
    notify => Exec['tailscale-up'],
  }

  exec { 'tailscale-up':
    refreshonly => true,
    command => 'tailscale up',
  }
}
