class role::everything {
  # Break out into actual roles here later.
  class { 'hyper_docker':
    nginxproxy_default_host => 'hyper.equipment',
  }

  # Main instance
  hyper_calckey { 'hyper.equipment':
    version            => 'v13.0.4',
    additional_domains => ['multi.equipment'],
    is_production      => true,
  }

  # Testing instance
  hyper_calckey { 'double.hyper.equipment':
    version      => 'v13.0.4',
    compose_name => 'double_calckey',
  }

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
