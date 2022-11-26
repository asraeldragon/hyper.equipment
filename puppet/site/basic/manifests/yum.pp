class basic::yum {
  # Setup the pieces and their dependency orders
  include basic::yum::config
  include basic::yum::packages

  # Ensure that all this stuff happens before YUM is used
  Class['basic::yum::config'] ->
  Class['basic::yum::packages'] ->
  Package <|
    provider == 'yum'
    and title != 'puppet-agent'
    and title != 'puppet'
  |>
}
