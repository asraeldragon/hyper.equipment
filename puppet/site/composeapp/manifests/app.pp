define composeapp::app (
  Pattern[/\A(git|http).+/] $url,
  String $owner                 = 'root',
  String $group                 = 'root',
  String $revision              = 'master',
  Optional[Hash] $cron_config   = undef,
  Boolean $backup               = false,
  Optional[Hash] $ssl           = undef,

  String $compose_file = "docker-compose.yaml",
  Array $override_compose_files = [],

  Hash $manage_volumes          = {},
  Hash $root_options = {},
  Hash $volumes_options = {},
) {
  $resource_title = $title
  ensure_packages(['git'], {'ensure' => 'present'})

  $composeroot = '/opt/compose'
  $root = "${composeroot}/${resource_title}"
  $reporoot = "${root}/repo"
  $volumeroot = "${root}/volumes"


  file { $root:
    * => {
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '2770',
    } + $root_options
  } ->

  # App composition data
  vcsrepo { $reporoot:
    ensure   => latest,
    provider => 'git',
    source   => $url,
    revision => $revision,
    user     => $owner,
    notify   => Docker_compose[$resource_title],
  } ->

  file { $volumeroot:
    * => {
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '2770',
    } + $volumes_options
  }

  if( $backup ) {
    if( $cron_config ) {
      $cronhash = $cron_config
    } else {
      $cronhash = {
        ensure   => present,
        command  => "${composeroot}/${resource_title}/backup.sh",
        user     => $user,
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
    compose_files => ["${reporoot}/${compose_file}"] + $override_compose_files,
    tag           => $resource_title,
    require       => [
      # Mount["${storageroot}/${resource_title}"],
      Vcsrepo["${composeroot}/${resource_title}/repo"]
    ],
    # notify        => Docker::Run['nginxproxy'],
  }
}
