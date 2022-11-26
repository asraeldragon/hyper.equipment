class basic::networking::ssl (
  Optional[Hash] $trusted_certificates = undef
) {
  class { 'trusted_ca': }

  # Add all trusted certificates.
  if( $trusted_certificates ) {
    each($trusted_certificates) |$kv| {
      $real_hostname = regsubst($kv[0], '_', '.', 'G')
      trusted_ca::ca { $real_hostname:
        content => $kv[1],
      }
    }

    # Ensure that this happens before anything that might need it.
    Trusted_ca::Ca <| |> -> Vcsrepo <| |>
    Trusted_ca::Ca <| |> -> Service <| |>
    Trusted_ca::Ca <| |> -> Archive <| |>
  }
}
