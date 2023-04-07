define hyper_calckey (
  String $version,
  String $main_domain = $title,
  Array $additional_domains = [],

  # Should only be true for one instance of this, until I genericize resource names and paths.
  # but realistically I only need this for my main env so whatever
  Boolean $is_production = false,

  # Sucky variable to allow different deploys
  # Should be updated to use main domain at some point.
  String $compose_name = 'calckey',

  Integer $uid = 0,
) {
  # aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  # $uid = 997

  $postgres_db = lookup('calckey::postgres::db')
  $postgres_user = lookup('calckey::postgres::user')
  $postgres_pass = lookup('calckey::postgres::password')

  $composeroot = '/opt/compose'
  $root = "${composeroot}/${compose_name}"
  $reporoot = "${root}/repo"
  $volumeroot = "${root}/volumes"
  $composefile = "${root}/docker-compose.yaml"
  $composeenv = "${root}/docker.env"

  $configroot = "${volumeroot}/config"
  $configyaml = "${configroot}/default.yml"

  # # Setup before launching Docker Compose
  # user { 'calckey':
  #   ensure => present,
  #   uid => $uid,
  #   gid => $uid,
  #   expiry => absent,
  #   home => '/home/calckey',
  #   managehome => false,
  #   password => '!',
  #   purge_ssh_keys => true,
  #   system => true,
  #   shell => '/usr/bin/fish',
  # }

  # group { 'calckey':
  #   ensure => present,
  #   gid => $uid,
  #   members => ['calckey', 'asrael'],
  #   system => true,
  # } -> User['calckey']

  # # Make sure calckey is in docker group
  # exec { 'calckey-docker-group':
  #   unless => 'id -nG calckey | grep -qw docker',
  #   command => 'usermod -aG docker calckey',
  #   before => Composeapp::App['calckey'],
  #   require => [
  #     User['calckey'],
  #     Group['calckey'],
  #   ]
  # }


  # Setup file structure
  file {
    default:
      ensure => directory,
      owner  => $uid,
      group  => $uid,
      mode   => '2770',
      before => Docker_compose['calckey'],
    ;
    $root:;
    $volumeroot:;
    $configroot:;
    $configyaml:
      ensure  => file,
      mode    => '0660',
      content => hash2yaml({
        url           => "https://${main_domain}/",
        port          => 3000,
        db            => {
          host => db,
          port => 5432,
          db   => $postgres_db,
          user => $postgres_user,
          pass => $postgres_pass,
        },
        redis         => {
          host => redis,
          port => 6379,
        },
        elasticsearch => {
          host => es,
          port => 9200,
        },
        id            => aid,
      }),
    ;
    $composeenv:
      ensure  => file,
      mode    => '0660',
      content => @("HERE"/L)
      POSTGRES_PASSWORD=${postgres_pass}
      POSTGRES_USER=${postgres_user}
      POSTGRES_DB=${postgres_db}
      | HERE
    ;
    $composefile:
      ensure  => file,
      mode    => '0660',
      content => epp("${module_name}/docker-compose.yaml.epp", {
        virtual_host     => join(concat([$main_domain], $additional_domains), ','),
        container_prefix => $compose_name,
        container_tag    => $version,
        is_production    => $is_production,
      }),
    ;
  }


  # Run compose
  docker_compose { $compose_name:
    ensure        => present,
    compose_files => [$composefile],
    # require       => [
    #   User['calckey'],
    #   Group['calckey'],
    #   Exec['calckey-docker-group'],
    # ],
  }

  # Ensure that there's a very high file upload limit
  file { "/opt/compose/nginxproxy/vhost.d/${main_domain}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Docker::Run['nginxproxy'],
    content => @("HERE"/L)
    client_max_body_size 100m;
    | HERE
  }

  # Redirect alias domains to the main site
  $additional_domains.each |$domain| {
    file { "/opt/compose/nginxproxy/vhost.d/${domain}_location":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0660',
      notify  => Docker::Run['nginxproxy'],
      content => @("HERE"/L$)
      location = /.well-known/webfinger {
        if ( \$query_string ~ "(.*)resource=acct(:|%3A)((?:@|%40)?[^@%]+)(@|%40)([^&]+)(.*)" ) {
          return 302 https://${main_domain}/.well-known/webfinger?\$1resource=acct\$2\$3\$4${main_domain}\$6;
        }
      }
      | HERE
    }
  }

  if( $is_production ) {
    # Backups
    $backup_script_location = '/root/calckey_backup.sh'
    file { $backup_script_location:
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0664',
      source => "puppet:///modules/${module_name}/rclone_backup.sh",
    }

    # would use rclone::config::s3, but it limits the options we can set, so no thanks
    rclone::config { 'wasabi':
      ensure  => present,
      type    => 's3',
      os_user => 'root',
      options => {
        env_auth          => 'false',
        endpoint          => 's3.us-east-2.wasabisys.com',
        bucket_acl        => 'private',
        disable_checksum  => 'true',
        no_check_bucket   => 'true',
        acl               => 'private',
        access_key_id     => lookup('rclone::config::s3::access_key_id'),
        secret_access_key => lookup('rclone::config::s3::secret_access_key'),
      },
    }

    rclone::config { 'encrypted':
      ensure  => present,
      type    => 'crypt',
      os_user => 'root',
      options => {
        remote                    => 'wasabi:',
        filename_encryption       => 'off',
        directory_name_encryption => 'false',
        password                  => lookup('rclone::config::encrypted::password'),
        password2                 => lookup('rclone::config::encrypted::password2'),
      },
    }

    cron { 'calckey_backup':
      ensure   => present,
      command  => "/bin/bash ${backup_script_location}",
      user     => 'root',
      month    => absent,
      monthday => absent,
      weekday  => absent,
      hour     => 0,
      minute   => 0,
    }
  }


  # Monitoring

}
