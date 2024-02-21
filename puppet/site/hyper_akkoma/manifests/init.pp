class hyper_akkoma {
  $akkoma_uid = 998

  composeapp::app { 'akkoma':
    url => 'https://akkoma.dev/AkkomaGang/akkoma.git',
    revision => 'stable',
    owner => 'akkoma',
    group => 'akkoma',
  }

  # Make sure there is a pgdata dir before launching docker compose
  Vcsrepo['/opt/compose/akkoma'] ->
  file { '/opt/compose/akkoma/pgdata':
    ensure => directory,
    owner  => $akkoma_uid,
    group  => $akkoma_uid,
    mode   => '2770',
  } -> Docker_compose['akkoma']

  user { 'akkoma':
    ensure => present,
    uid => $akkoma_uid,
    gid => $akkoma_uid,
    expiry => absent,
    home => '/home/akkoma',
    managehome => false,
    password => '!',
    purge_ssh_keys => true,
    system => true,
    shell => '/usr/bin/fish',
  }

  group { 'akkoma':
    ensure => present,
    gid => $akkoma_uid,
    members => ['akkoma', 'asrael'],
    system => true,
  } -> User['akkoma'] -> Composeapp::App['akkoma']

  # Make sure akkoma is in docker group
  exec { 'akkoma-docker-group':
    unless => 'id -nG akkoma | grep -qw docker',
    command => 'usermod -aG docker akkoma',
  }

  # First run resources
}
