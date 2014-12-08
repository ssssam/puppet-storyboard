# Copyright (c) 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: storyboard::workers
#
# This module installs the storyboard deferred processing workers.
#
class storyboard::workers (
  $worker_count = 5,
  $use_upstart = false,
  $use_systemd = false
) {

  include storyboard::params

  $systemd_path = '/etc/systemd/system/storyboard-workers.service'
  $upstart_path = '/etc/init/storyboard-workers.conf'
  $sysvinit_path = '/etc/init.d/storyboard-workers'

  if $use_systemd {
    file { $systemd_path:
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('storyboard/storyboard-workers.service.erb'),
      notify  => Service['storyboard-workers'],
      before  => Service['storyboard-workers'],
    }
    file { $upstart_path:
      ensure => absent
    }
    file { $sysvinit_path:
      ensure => absent
    }
  } elsif $use_upstart {
    file { $upstart_path:
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('storyboard/storyboard-workers.conf.erb'),
      notify  => Service['storyboard-workers'],
      before  => Service['storyboard-workers'],
    }
    file { $sysvinit_path:
      ensure => absent
    }
    file { $systemd_path:
      ensure => absent
    }
  } else {
    file { $systemd_path:
      ensure => absent
    }
    file { $upstart_path:
      ensure => absent
    }
    file { $sysvinit_path:
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0755',
      content => template('storyboard/storyboard-workers.sh.erb'),
      notify  => Service['storyboard-workers'],
      before  => Service['storyboard-workers'],
    }
  }

  service { 'storyboard-workers':
    ensure     => running,
    hasrestart => true,
    subscribe  => [
      Class['::storyboard::application']
    ],
    require    => [
      Class['::storyboard::application']
    ]
  }
}
