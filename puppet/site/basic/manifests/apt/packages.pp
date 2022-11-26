class basic::apt::packages {
  package {[
    'apt-transport-https',
    ]:
    ensure => latest,
    tag    => 'prepare-apt-packages',
  }

  package { 'puppet':
    ensure => purged,
    tag    => 'prepare-apt-packages',
    notify => Exec['apt_autoremove'],
  }

  exec { 'apt_autoremove':
    path        => '/bin:/sbin:/usr/bin/:/usr/sbin',
    command     => 'apt autoremove -y',
    refreshonly => true,
  }

  # Post-prepare packages that should be on everything
  package {['screen', 'et', 'fish-shell']:
    ensure => latest,
  }

}
