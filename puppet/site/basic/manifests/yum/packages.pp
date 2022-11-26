class basic::yum::packages {
  $package_list = lookup('install_packages', Optional[Any], 'unique', undef)
  if( $package_list ) {
    ensure_packages($package_list, {ensure => present})
  }

  Package <| provider == 'yum' |> -> Vcsrepo <| |>
  Package <| provider == 'yum' |> -> Exec <| |>
}
