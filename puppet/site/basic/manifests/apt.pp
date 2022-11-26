class basic::apt {
  # Setup the pieces and their dependency orders
  include basic::apt::config
  include basic::apt::packages

  # Ensure that all this stuff happens before APT is used
  Apt::Conf <| |> ->
  Apt::Source <| |> ->
  Exec['apt_update'] ->
  Package <|
    provider == 'apt'
    and tag == 'prepare-apt-packages'
  |> ->
  Package <|
    provider == 'apt'
  |>
}
