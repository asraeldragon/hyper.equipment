class basic::sshd {
  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'X11Forwarding' => 'no',
      'PasswordAuthentication' => 'no',
      'PermitRootLogin' => 'no',
      'AllowAgentForwarding' => 'no',
      'AllowTcpForwarding' => 'no',
      'PubkeyAuthentication' => 'yes',
      'Port' => [59365],
    },
  }

  ::ssh::client::config::user { 'root':
    ensure => present,
    user_home_dir => '/root',
    options => {
      'Host *' => {
        'IdentitiesOnly' => 'Yes',
        'StrictHostKeyChecking' => 'No',
      },
      'Host github.com' => {
        'User' => 'git',
        'IdentityFile' => '~/.ssh/git_ed25519',
      },
    },
  }

  # key not included, might set up later

  ::ssh::client::config::user { 'asrael':
    ensure => present,
    options => {
      '*' => {
        'IdentitiesOnly' => 'Yes',
        'StrictHostKeyChecking' => 'No',
      },
    },
  }
}
