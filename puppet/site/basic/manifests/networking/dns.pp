class basic::networking::dns (
  Array $nameservers,
  Array $search_domains = [],
) {
  # Assemble resolv.conf
  $search_lines = $search_domains.map |$line| { "search ${line}" }
  $nameserver_lines = $nameservers.map |$line| { "nameserver ${line}" }

  $all_lines = [
    $search_lines.join("\n"),
    "\n",
    $nameserver_lines.join("\n"),
    "\n"
  ].join('')

  file { '/etc/resolv.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $all_lines,
  }

  # Realize all exported DNS lines for this cloud.
  # This doesn't work now, but may be useful when we have a PuppetDB.
  # File_line <<| tag == "dns-${$facts['cloud']}" |>>

  # Emergency DNS backup -- should be changed when Puppet gets behind a load balancer
  host { 'puppet':
    ensure => present,
    ip     => $server_facts['serverip'],
  }
}
