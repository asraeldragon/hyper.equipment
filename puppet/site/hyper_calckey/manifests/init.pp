class hyper_calckey {
  # aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  $calckey_uid = 0
  # $calckey_uid = 997

  $composeroot = '/opt/compose'
  $root = "${composeroot}/calckey"
  $reporoot = "${root}/repo"
  $volumeroot = "${root}/volumes"
  $composefile = "${root}/docker-compose.yaml"
  $composeenv = "${root}/docker.env"

  $configroot = "${volumeroot}/config"
  $configyaml = "${configroot}/default.yml"

  # # Setup before launching Docker Compose
  # user { 'calckey':
  #   ensure => present,
  #   uid => $calckey_uid,
  #   gid => $calckey_uid,
  #   expiry => absent,
  #   home => '/home/calckey',
  #   managehome => false,
  #   password => '!',
  #   purge_ssh_keys => true,
  #   system => true,
  #   shell => '/usr/bin/fish',
  # }

  # group { 'calckey':
  #   ensure => present,
  #   gid => $calckey_uid,
  #   members => ['calckey', 'asrael'],
  #   system => true,
  # } -> User['calckey']

  # # Make sure calckey is in docker group
  # exec { 'calckey-docker-group':
  #   unless => 'id -nG calckey | grep -qw docker',
  #   command => 'usermod -aG docker calckey',
  #   before => Composeapp::App['calckey'],
  #   require => [
  #     User['calckey'],
  #     Group['calckey'],
  #   ]
  # }

  # Setup file structure
  file {
    default:
      ensure => directory,
      owner => $calckey_uid,
      group => $calckey_uid,
      mode => '2770',
      before => Docker_compose['calckey'],
    ;
    $root:;
    $volumeroot:;
    $configroot:;
    $configyaml:
      ensure => file,
      mode => '0660',
      source => 'file:///root/calckey_config.yml', # actually sensitive so it gets pulled from elsewhere in a manual step
    ;
    $composeenv:
      ensure => file,
      mode => '0660',
      content => @("HERE"/L)
      POSTGRES_PASSWORD=calckey
      POSTGRES_USER=calckey
      POSTGRES_DB=calckey
      | HERE
    ;
    $composefile:
      ensure => file,
      mode => '0660',
      source => "puppet:///modules/${module_name}/docker-compose.yaml",
    ;
  }

  # Run compose
  docker_compose { 'calckey':
    ensure        => present,
    compose_files => [$composefile],
    # require       => [
    #   User['calckey'],
    #   Group['calckey'],
    #   Exec['calckey-docker-group'],
    # ],
  }
}
