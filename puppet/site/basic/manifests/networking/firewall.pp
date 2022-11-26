class basic::networking::firewall {
  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }
}
