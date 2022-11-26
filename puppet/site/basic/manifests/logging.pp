class basic::logging {
  # Configure memory limits for rsyslog
  file_line {
    default:
      ensure => present,
      path   => '/usr/lib/systemd/system/rsyslog.service',
      notify => Exec['restart rsyslog'],
    ;
    'MemoryHigh for rsyslog':
      after => '\[Service\]',
      line  => 'MemoryHigh=512M',
      match => '^MemoryHigh=',
    ;
    'MemoryLimit for rsyslog':
      after => '^MemoryHigh=',
      line  => 'MemoryLimit=768M',
      match => '^MemoryLimit=',
    ;
  }

  exec { 'restart rsyslog':
    refreshonly => true,
    command     => '/usr/bin/systemctl daemon-reload && /usr/bin/systemctl restart rsyslog',
  }
}
