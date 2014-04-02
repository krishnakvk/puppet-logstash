require 'spec_helper_acceptance'

if fact('osfamily') != 'Suse'

describe "Logstash class:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
  when 'RedHat'
    package_name = 'logstash'
		service_name = 'logstash'
    url          = 'https://download.elasticsearch.org/logstash/logstash/packages/centos/logstash-1.4.0-1_c82dc09.noarch.rpm'
    local        = '/tmp/logstash-1.4.0-1_c82dc09.noarch.rpm'
    puppet       = 'logstash-1.4.0-1_c82dc09.noarch.rpm'
		pid_file     = '/var/run/logstash/logstash.pid'
  when 'Debian'
    package_name = 'logstash'
		service_name = 'logstash'
    url          = 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.0-1-c82dc09_all.deb'
    local        = '/tmp/logstash_1.4.0-1-c82dc09_all.deb'
    puppet       = 'logstash_1.4.0-1-c82dc09_all.deb'
		pid_file     = '/var/run/logstash.pid'
  end

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  curl_with_retries('Download package for local file test', default, "#{url} -o #{local}", 0)
  shell("cp #{local} #{default['distmoduledir']}/another/files/#{puppet}")

  context "install via http resource" do

    it 'should run successfully' do
			pp = "class { 'logstash': package_url => '#{url}', java_install => true, config => { 'node.name' => 'logstash001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
	    it { should be_file }
		  its(:content) { should match /[0-9]+/ }
	  end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'logstash': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via local file resource" do

    it 'should run successfully' do
			pp = "class { 'logstash': package_url => 'file:#{local}', java_install => true, config => { 'node.name' => 'logstash001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
	    it { should be_file }
		  its(:content) { should match /[0-9]+/ }
	  end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'logstash': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running } 
    end

  end

  context "Install via Puppet resource" do

    it 'should run successfully' do
			pp = "class { 'logstash': package_url => 'puppet:///modules/another/#{puppet}', java_install => true, config => { 'node.name' => 'logstash001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 10
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
	    it { should be_file }
		  its(:content) { should match /[0-9]+/ }
	  end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'logstash': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end

end