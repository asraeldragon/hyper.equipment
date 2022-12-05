class hyper_akkoma {
  class { 'hyper_akkoma::cloudflared': }

  composeapp::app { 'akkoma':
    url => 'https://akkoma.dev/AkkomaGang/akkoma.git',
    revision => 'stable',
    owner => 'akkoma',
    group => 'akkoma',
  }

  $akkoma_uid = 115
  user { 'akkoma':
    ensure => present,
    uid => $akkoma_uid,
    gid => $akkoma_uid
    expiry => absent,
    home => '/opt/compose/akkoma',
    managehome => false,
    password => '!',
    purge_ssh_keys => true,
    system => true,
  }

  group { 'akkoma':
    ensure => present,
    gid => $akkoma_uid,
    members => ['akkoma', 'asrael'],
    system => true,
  } -> User['akkoma'] -> Composeapp::app['akkoma']

  # First run resources
}
