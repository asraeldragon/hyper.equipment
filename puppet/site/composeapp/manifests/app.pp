# == Class: composeapp
#
# Full description of class composeapp here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'composeapp':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2016 Your name here, unless otherwise noted.
#
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

  # $prodpath = '/volume1/Data/Production'
  # $backupspath = '/volume1/Data/Backups'

  # $storageroot = hiera('storageroot')
  $composeroot = hiera('composeroot')
  # $backupsroot = hiera('backupsroot')

  # $user = 'svc_temp_fsacct'
  # $pass = hiera("secure::passwords::svc_temp_fsacct")

  $per_app_key = lookup("checkout_key::${resource_title}")
  file { "/root/.ssh/puppet_${resource_title}_key":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => $per_app_key,
  }

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

  if( $ssl =~ Hash ) {

    # $no_wildcard_name = regsubst($ssl_name, '^\*\.', '')
    # $period_name = regsubst($no_wildcard_name, '_', '.', 'G')
    ensure_resource('file', "${composeroot}/nginxproxy/ssl/${$ssl['name']}.crt", {
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      tag     => 'ssl',
      content => $ssl['cert']
    })

    ensure_resource('file', "${composeroot}/nginxproxy/ssl/${$ssl['name']}.key", {
      ensure  => file,
      mode    => '0400',
      owner   => 'root',
      group   => 'root',
      tag     => 'ssl',
      content => $ssl['key']
    })

    File <| tag =='ssl' |> -> Docker_compose <| |>
    File <| tag =='ssl' |> ~> Docker::Run['nginxproxy']
  }

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
