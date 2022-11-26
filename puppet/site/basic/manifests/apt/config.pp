class basic::apt::config {
  apt::conf { 'No suggestions or recommendations':
    ensure        => present,
    notify_update => false,
    priority      => '00',
    content       => @("CONF")
    APT::Get::Install-Suggests "false";
    APT::Get::Install-Recommends "false";
    |-CONF
  }

  apt::source { 'puppetlabs':
    location      => 'http://apt.puppetlabs.com',
    notify_update => true,
    repos         => 'PC1',
    key           => {
      'id'     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      'server' => 'pgp.mit.edu',
    },
  }

  apt::ppa { 'ppa:fish-shell/release-3': }

  # Update Apt sources once a week, randomly
  $weekday = fqdn_rand(7)
  $hour = fqdn_rand(24)
  cron { 'periodic update':
    ensure   => present,
    command  => 'apt-get update',
    user     => 'root',
    month    => absent,
    monthday => absent,
    weekday  => $weekday,
    hour     => $hour,
    minute   => 0
  }

  # Ability to upgrade via facts
  if( $facts['upgrade'] ) {
    exec { 'normal upgrade':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'apt-get upgrade -y'
    }
  }

  if( $facts['dist_upgrade'] ) {
    exec { 'dist upgrade':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'apt-get dist-upgrade -y'
    }
  }
}
