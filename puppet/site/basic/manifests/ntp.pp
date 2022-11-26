class basic::ntp {
  # Use Chrony -- servers will be in Hiera
  class { '::chrony': }
}
