class basic::networking::proxy (
  Optional[Variant[Hash,Boolean]] $http = undef,
  Optional[Variant[Hash,Boolean]] $https = undef,
  Optional[Variant[String,Boolean]] $no = undef,
) {
  # Hashes should be of form:
  # hash:
  #   protocol: <optional>
  #   url: <name or ip>
  #   port: number

  # Create files that contain proxy information
  # This propagates among all shells.
  file {
    default:
      owner => 'root',
      group => 'root',
      mode  => '0644',
      tag   => 'proxy',
    ;
    '/etc/profile.d/http-proxy.sh':
      * => ($http =~ Hash) ? {
        true    => {
          ensure  => present,
          content => [
            'export http_proxy=',
            $http['protocol'], '://', $http['url'], ':', $http['port'],
            "\n"
          ].join(''),
        },
        default => { ensure => absent },
      }
    ;
    '/etc/profile.d/https-proxy.sh':
      * => ($https =~ Hash) ? {
        true    => {
          ensure  => present,
          content => [
            'export https_proxy=',
            $https['protocol'], '://', $https['url'], ':', $https['port'],
            "\n"
          ].join(''),
        },
        default => { ensure => absent },
      }
    ;
    '/etc/profile.d/no-proxy.sh':
      * => ($no =~ String) ? {
        true    => {
          ensure  => present,
          content => "export no_proxy=${no}\n",
        },
        default => { ensure => absent },
      }
    ;
  }

  # Ensure that this happens before anything that might need it.
  File <| tag == 'proxy' |> -> Exec <| |>
  File <| tag == 'proxy' |> -> Service <| |>
  File <| tag == 'proxy' |> -> Archive <| |>
}
