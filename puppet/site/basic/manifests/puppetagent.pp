class basic::puppetagent (
  String $server_url,
  Boolean $auto_puppet = true,
  Boolean $debug_puppet = false,
  String $log_location = '/var/log/puppet_agent.log',
){
  # Puppet "service" management
  service { 'puppet':
    ensure => stopped,
    enable => false,
  }

  package { 'puppet6-release':
    * => $facts['os']['family'] ? {
      'RedHat' => {
        ensure   => installed,
        source   => "https://yum.puppet.com/puppet6-release-el-${$facts['os']['release']['major']}.noarch.rpm",
        provider => 'rpm',
      },
      'Debian' => {
        ensure   => installed,
        source   => "https://apt.puppetlabs.com/puppet6-release-${$facts['os']['distro']['codename']}.deb",
        provider => 'dpkg',
      },
      default  => {
        ensure   => installed,
      }
    }
  }

  package { 'puppet-agent':
    ensure  => latest,
    require => Package['puppet6-release'],
  }

  $offset = fqdn_rand(60)
  cron { 'puppet agent -t':
    ensure   => $auto_puppet ? {
      true    => present,
      default => absent,
    },
    command  => 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin /opt/puppetlabs/puppet/bin/puppet agent -t &>> /var/log/puppet_agent.log',
    user     => 'root',
    month    => absent,
    monthday => absent,
    weekday  => absent,
    hour     => absent,
    minute   => $offset,
  }

  logrotate::rule { 'puppet_agent':
    path         => $log_location,
    rotate       => 3,
    rotate_every => 'week',
    # postrotate   => '/usr/bin/killall -HUP syslogd',
  }

  if( $::trusted['certname'] == $::server_facts['servername'] ) {
    $template = 'puppet.conf.server'
  } else {
    $template = 'puppet.conf.agent'
  }

  file { "${settings::confdir}/puppet.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/${template}.epp", {
        'server_url' => $server_url,
    }),
  }
}
