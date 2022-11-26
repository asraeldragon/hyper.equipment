class hyper_docker {
  class { 'docker':
    docker_users => ['asrael'],
  }

  class { 'docker::compose':
    ensure => present,
  }
}
