apt_package "default-jdk"

remote_file '/var/tmp/swarm-client-3.3.jar' do
  source 'https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.3/swarm-client-3.3.jar'
  owner 'ubuntu'
  group 'ubuntu'
  action :create
end

execute 'swarm-client' do
  command 'java -jar /var/tmp/swarm-client-3.3.jar -autoDiscoveryAddress 192.168.50.255 -executors 1 -name jenkins_slave_linux > /tmp/swarm.log 2>&1 &'
  creates '/tmp/swarm.log'
end
