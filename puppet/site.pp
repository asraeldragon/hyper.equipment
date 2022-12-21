node default {
  # Specify Exec defaults so we don't have to every time
  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
  }

  class { 'role::everything': }
}
