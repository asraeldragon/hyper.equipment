class basic (
  Hash $os_hardening_overrides = {},
  Optional[Hash] $lvm = undef,
) {
  class { 'basic::hostname': }
  # class { 'basic::networking': } # Later

  case $facts['os']['family'] {
    'RedHat', 'CentOS': {
      class { 'basic::yum': }
      class { 'basic::selinux': }
      class { 'basic::logging': }
    }
    'Debian', 'Ubuntu': {
      class { 'basic::apt': }
      class { 'basic::ufw': }
    }
    default:            {}
  }

  class { 'basic::ntp': }
  class { 'basic::sshd': }

  # class { 'users': } # Later

  class { 'basic::puppetagent': }

  sysctl { 'vm.swappiness': value => '10' }

  class{ 'os_hardening':
    * => {
      enable_log_martians => false,
      manage_system_users => false, # Attempts to redeclare users we already declare elsewhere. Annoyingly. We don't have hiera to manage this so ignore it.
    } + $os_hardening_overrides,
  }

  logrotate::conf { '/etc/logrotate.conf':
    rotate       => 10,
    rotate_every => 'week',
    ifempty      => true,
    dateext      => true,
  }

  # Probably never
  # # Manage LVM, if we have options.
  # if( $lvm ) {
  #   class { 'lvm': * => $lvm, }
  # }

  # Maybe MOTD
}
