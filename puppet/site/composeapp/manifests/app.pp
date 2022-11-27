define composeapp::app (
  Pattern[/\A(git|http).+/] $url,
  String $revision              = 'master',
  Optional[Hash] $cron_config   = undef,
  # String $mountdevice         = hiera('composedevice'),
  Boolean $backup               = false,
  Optional[Hash] $ssl           = undef,
  Hash $manage_volumes          = {},
  Hash $root_options = {},
  Hash $volumes_options = {},
) {
  $resource_title = $title
  ensure_packages(['git'], {'ensure' => 'present'})

  # $storageroot = hiera('storageroot')
  # $composeroot = hiera('composeroot')
  # $backupsroot = hiera('backupsroot')

  $composeroot = '/opt/compose'

  file { "${composeroot}/${resource_title}":
    * => {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0770',
    } + $root_options
  } ->

  # App composition data
  vcsrepo { "${composeroot}/${resource_title}":
    ensure   => latest,
    provider => 'git',
    source   => $url,
    revision => $revision,
    user     => 'root',
    require  => File["/root/.ssh/puppet_${resource_title}_key"],
    notify   => Docker_compose[$resource_title],
  } ->

  file { "${composeroot}/${resource_title}/volumes":
    * => {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0770',
    } + $volumes_options
  }

  if( $backup ) {
    if( $cron_config ) {
      $cronhash = $cron_config
    } else {
      $cronhash = {
        ensure   => present,
        command  => "${composeroot}/${resource_title}/backup.sh",
        user     => 'root',
        month    => absent,
        monthday => absent,
        weekday  => absent,
        hour     => 0,
        minute   => 0,
      }
    }

    cron { $resource_title:
      * => $cronhash,
    }
  }

  # if( $ssl =~ Hash ) {

  #   # $no_wildcard_name = regsubst($ssl_name, '^\*\.', '')
  #   # $period_name = regsubst($no_wildcard_name, '_', '.', 'G')
  #   ensure_resource('file', "${composeroot}/nginxproxy/ssl/${$ssl['name']}.crt", {
  #     ensure  => file,
  #     mode    => '0644',
  #     owner   => 'root',
  #     group   => 'root',
  #     tag     => 'ssl',
  #     content => $ssl['cert']
  #   })

  #   ensure_resource('file', "${composeroot}/nginxproxy/ssl/${$ssl['name']}.key", {
  #     ensure  => file,
  #     mode    => '0400',
  #     owner   => 'root',
  #     group   => 'root',
  #     tag     => 'ssl',
  #     content => $ssl['key']
  #   })

  #   File <| tag =='ssl' |> -> Docker_compose <| |>
  #   File <| tag =='ssl' |> ~> Docker::Run['nginxproxy']
  # }

  docker_compose { $resource_title:
    ensure        => present,
    compose_files => ["${composeroot}/${resource_title}/docker-compose.yaml"],
    tag           => $resource_title,
    require       => [
      # Mount["${storageroot}/${resource_title}"],
      Vcsrepo["${composeroot}/${resource_title}"]
    ],
    notify        => Docker::Run['nginxproxy'],
  }
}
