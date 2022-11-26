class role::everything {
  # Break out into actual roles here later.
  class { 'hyper_docker': }

  class { 'hyper_akkoma': }
  class { 'hyper_portainer': }
  class { 'hyper_postgres': }

  # Add IPv4 forwarding if this host has Docker.
  $has_docker = true
  class { 'basic':
    os_hardening_overrides =>{
        enable_ipv4_forwarding => true,
    },
  }
}
