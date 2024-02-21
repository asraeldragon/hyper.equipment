class basic::networking {
  # sysctl { 'net.ipv6.conf.all.disable_ipv6': value => '1' }
  # sysctl { 'net.ipv6.conf.default.disable_ipv6': value => '1' }
  # sysctl { 'net.ipv6.conf.lo.disable_ipv6': value => '1' }

  class { 'basic::networking::dns': }
  class { 'basic::networking::firewall': }
  class { 'basic::networking::proxy': }
  class { 'basic::networking::ssl': }
  class { 'basic::networking::cloudflared': }
}
