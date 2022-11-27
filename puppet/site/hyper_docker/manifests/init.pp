class hyper_docker (
  Optional[String] $nginxproxy_default_host = undef,
) {
  class { 'docker':
    docker_users => ['asrael'],
  }

  class { 'docker::compose':
    ensure => present,
  }

  # composeapp stuff
  $run_nginxproxy = true
  $composeroot = '/opt/compose'
  class {'docker::compose':
    ensure  => present,
  }

  file {
    default:
      ensure => $run_nginxproxy ? {
        true    => directory,
        default => absent,
      },
      mode   => '0700',
      owner  => 'root',
      group  => 'root',
    ;
    $composeroot:
      mode => '0777',
    ;
    "${composeroot}/nginxproxy":;
    "${composeroot}/nginxproxy/ssl":;
    "${composeroot}/nginxproxy/vhost.d":;
    "${composeroot}/nginxproxy/special.d":;
  }

    # Include a special directory not managed by Puppet to give manual Nginxproxy configs
    file { "${composeroot}/nginxproxy/special.d.conf":
      ensure  => $run_nginxproxy ? {
        true    => file,
        default => absent,
      },
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => "include /etc/nginx/special.d/*.conf;\n",
    }

    docker_network { 'nginxproxy_dmz':
      ensure => $run_nginxproxy ? {
        true    => present,
        default => absent,
      },
    }

    docker::run { 'nginxproxy':
      ensure           => $run_nginxproxy ? {
        true    => present,
        default => absent,
      },
      image            => $use_registry ? {
        true    => [ $registry_url, 'jwilder', 'nginx-proxy:alpine' ].join('/'),
        default => [ 'jwilder', 'nginx-proxy:alpine' ].join('/'),
      },
      ports            => ['80:80', '443:443'],
      net              => 'nginxproxy_dmz',
      extra_parameters => [ '--restart=always', '--log-driver=none' ],
      env              => ($nginxproxy_default_host =~ Undef) ? {
        true    => [],
        default => ["DEFAULT_HOST=${nginxproxy_default_host}"],
      },
      volumes          => [
        '/var/run/docker.sock:/tmp/docker.sock:ro',
        "${composeroot}/nginxproxy/ssl:/etc/nginx/certs",
        "${composeroot}/nginxproxy/special.d.conf:/etc/nginx/conf.d/special.d.conf",
        "${composeroot}/nginxproxy/special.d:/etc/nginx/special.d",
        "${composeroot}/nginxproxy/vhost.d:/etc/nginx/vhost.d",
      ],
      require          => File["${composeroot}/nginxproxy/special.d.conf"],
    }
}
