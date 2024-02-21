class basic::networking::cloudflared (
  String $token,
) {
  docker::run { 'nginxproxy':
    ensure           => present,
    image            => 'cloudflare/cloudflared:latest',
    net              => 'nginxproxy_dmz',
    extra_parameters => [ '--restart=always', '--log-driver=none' ],
    command          => "--no-autoupdate run --token ${token}",
  }
}
