class basic::yum::config {

  # Ability to upgrade via facts
  if( $facts['upgrade'] ) {
    exec { 'normal upgrade':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      command => 'yum upgrade -y'
    }
  }

  $yum_file = {
    ensure            => present,
    path              => '/etc/yum.conf',
    match_for_absence => true,
    replace           => true,
    multiple          => true,
  }

  file_line { 'yum timeout':
    *     => $yum_file,
    line  => 'timeout=3',
    match => '^timeout=',
  }

  $https_proxy = lookup('basic::networking::proxy::https', {default_value => false})
  if( $https_proxy and $facts['role'] != 'Bastion' ) {
    file_line { 'yum proxy':
      *     => $yum_file,
      match => '\s*proxy=.*',
      line  => [
        'proxy=https://',
        $https_proxy['url'], ':', $https_proxy['port'],
      ].join(''),
    }
  } else {
    file_line { 'yum proxy':
      *     => $yum_file + {ensure => absent},
      match => '\s*proxy=.*',

    }
  }

  yumrepo {
    default:
      tag => 'general-yumrepo',
    ;
    'puppet5': ensure => absent;
    'puppet5-source': ensure => absent;
    'puppet':
      descr    => 'Puppet 6 Repository el 7 - $basearch',
      baseurl  => 'https://yum.puppetlabs.com/puppet6/el/7/$basearch',
      gpgkey   => 'https://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
      enabled  => '0',
      gpgcheck => '1',
    ;
    # 'elrepo':
    #   descr      => 'ELRepo.org Community Enterprise Linux Repository - el7',
    #   baseurl    => 'https://elrepo.org/linux/elrepo/el7/$basearch/',
    #   mirrorlist => 'http://mirrors.elrepo.org/mirrors-elrepo.el7', # wrong CN on cert
    #   enabled    => '1',
    #   gpgcheck   => '1',
    #   gpgkey     => 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
    #   protect    => '0',
    # ;
    # 'elrepo-testing':
    #   descr      => 'ELRepo.org Community Enterprise Linux Testing Repository - el7',
    #   baseurl    => 'https://elrepo.org/linux/testing/el7/$basearch/',
    #   mirrorlist => 'http://mirrors.elrepo.org/mirrors-elrepo-testing.el7', # wrong CN on cert
    #   enabled    => '0',
    #   gpgcheck   => '1',
    #   gpgkey     => 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
    #   protect    => '0',
    # ;
    'elrepo-kernel':
      descr      => 'ELRepo.org Community Enterprise Linux Kernel Repository - el7',
      baseurl    => 'https://elrepo.org/linux/kernel/el7/$basearch/',
      mirrorlist => 'http://mirrors.elrepo.org/mirrors-elrepo-kernel.el7', # wrong CN on cert
      enabled    => '0',
      gpgcheck   => '1',
      gpgkey     => 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
      protect    => '0',
    ;
    # 'elrepo-extras':
    #   descr      => 'ELRepo.org Community Enterprise Linux Extras Repository - el7',
    #   baseurl    => 'https://elrepo.org/linux/extras/el7/$basearch/',
    #   mirrorlist => 'http://mirrors.elrepo.org/mirrors-elrepo-extras.el7', # wrong CN on cert
    #   enabled    => '0',
    #   gpgcheck   => '1',
    #   gpgkey     => 'https://www.elrepo.org/RPM-GPG-KEY-elrepo.org',
    #   protect    => '0',
    # ;
  }

  class { 'epel': }

  Yumrepo <| tag == 'general-yumrepo' |> -> Class['epel'] -> Package <| |>
}
