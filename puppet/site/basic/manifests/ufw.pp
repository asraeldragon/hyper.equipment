class basic::ufw {
  class {'ufw':
    purge_unmanaged_rules  => true,
    purge_unmanaged_routes => true,
  }
}
