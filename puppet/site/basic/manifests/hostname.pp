class basic::hostname {
  # Fix the hostname to have its FQDN
  # $true_fqdn = downcase("$::hostname.funko.com")
  #
  # file { '/etc/hostname':
  #   ensure  => present,
  #   owner   => root,
  #   group   => root,
  #   mode    => '0644',
  #   content => "${true_fqdn}\n",
  #   notify  => Exec['set-hostname'],
  # }

  # Commit the hostname if it's been temporarily changed but not committed.
  exec { 'set-hostname':
    command     => '/bin/hostname -F /etc/hostname',
    refreshonly => true,
    unless      => '/usr/bin/test `hostname` = `/bin/cat /etc/hostname`',
    # notify      => Service[$rsyslog::params::service_name],
  }

  # host { [$::hostname, $true_fqdn]:
  #   ensure => present,
  #   ip     => '127.0.1.1'
  # }
}
