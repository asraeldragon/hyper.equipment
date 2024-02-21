class basic::networking::cloudflared (
  String $token,
) {
  docker::run { 'cloudflared':
    ensure           => present,
    image            => 'cloudflare/cloudflared:latest',
    net              => 'nginxproxy_dmz',
    extra_parameters => [ '--restart=always', '--log-driver=none' ],
    command          => "tunnel --no-autoupdate run --token ${token}",
  }
}
