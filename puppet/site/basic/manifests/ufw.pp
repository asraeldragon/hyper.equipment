class basic::ufw {
  class {'ufw':
    purge_unmanaged_rules  => true,
    purge_unmanaged_routes => true,
  }

  ufw_rule { 'allow mosh':
    ensure => present,
    action => 'allow',
    direction => 'in',
    to_ports_app => 'mosh',
  }
}
