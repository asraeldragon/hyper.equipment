class hyper_akkoma {
  class { 'hyper_akkoma::cloudflared': }

  composeapp::app { 'akkoma':
    url => 'https://akkoma.dev/AkkomaGang/akkoma.git',
    revision => 'stable',
  }

  # First run resources
}
