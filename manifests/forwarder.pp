class logstash::forwarder(
  $logstash_port,
  $logstash_host = 'localhost',
  ) {
  
  package { 'logstash-forwarder':
    ensure => present,
  }

  file { '/etc/logstash-forwarder':
    ensure => file,
    content => template('logstash/logstash-forwarder.erb'),
  }

  service { 'logstash-forwarder':
    ensure  => running,
    enabled => true,
    require => Package['logstash-forwarder'],
  }

}