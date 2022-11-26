class basic::selinux {
  file_line { 'disable selinux':
    ensure => present,
    path   => '/etc/selinux/config',
    line   => 'SELINUX=permissive',
    match  => '^SELINUX=',
  }

  exec { 'live disable selinux':
    command => '/sbin/setenforce 0',
    unless  => '/usr/bin/test `getenforce` = "Permissive"',
  }
}
