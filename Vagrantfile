# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :machine
  end

  config.vm.define "gluster-server-1" do |config|
    config.vm.network :private_network, ip: "192.168.50.5"

    config.vm.provision :shell, :inline => "apt-get update", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y software-properties-common", :privileged => true
    config.vm.provision :shell, :inline => "add-apt-repository ppa:gluster/glusterfs-3.8", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y glusterfs-server", :privileged => true
  end
  config.vm.define "gluster-server-2" do |config|
    config.vm.network :private_network, ip: "192.168.50.6"

    config.vm.provision :shell, :inline => "apt-get update", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y software-properties-common", :privileged => true
    config.vm.provision :shell, :inline => "add-apt-repository ppa:gluster/glusterfs-3.8", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y glusterfs-server", :privileged => true
    config.vm.provision :shell, :inline => "gluster peer probe 192.168.50.5", :privileged => true
    config.vm.provision :shell, :inline => "gluster volume create jenkins_home replica 2 transport tcp 192.168.50.5:/brick 192.168.50.6:/brick force", :privileged => true
    config.vm.provision :shell, :inline => "gluster volume start jenkins_home", :privileged => true
  end

  config.vm.define "jenkins-master-1" do |config|
    config.vm.network "private_network", ip: "192.168.50.11"

    # add repositories
    config.vm.provision :shell, :inline => "apt-get update", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y software-properties-common", :privileged => true
    config.vm.provision :shell, :inline => "add-apt-repository ppa:gluster/glusterfs-3.8", :privileged => true
    config.vm.provision :shell, inline: "wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -"
    config.vm.provision :shell, inline: "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'"
    config.vm.provision :shell, inline: "sudo apt-get update"

    # install & mount glusterfs
    config.vm.provision :shell, :inline => "apt-get install -y glusterfs-client", :privileged => true
    config.vm.provision :shell, :inline => "mkdir -p /var/lib/jenkins && sudo mount -t glusterfs 192.168.50.5:/jenkins_home /var/lib/jenkins", :privileged => true

    ### install Jenkins
    config.vm.provision :shell, inline: "sudo apt-get -y install jenkins"
    config.vm.provision :shell, inline: "sleep 10"
    ### configure jenkins
    config.vm.provision :shell, inline: "cp /var/lib/jenkins/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion", :privileged => true
    config.vm.provision :shell, inline: "cp /vagrant/jenkins/config.xml_template /var/lib/jenkins/config.xml", :privileged => true
    config.vm.provision :shell, inline: "cp /vagrant/jenkins/jenkins.model.JenkinsLocationConfiguration.xml_template /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml", :privileged => true
    config.vm.provision :shell, inline: "chown -R jenkins:jenkins /var/lib/jenkins/", :privileged => true
    config.vm.provision :shell, inline: "chmod -R 777 /var/lib/jenkins/", :privileged => true
    config.vm.provision :shell, inline: "service jenkins restart", :privileged => true
    config.vm.provision :shell, inline: "sleep 10"
    config.vm.provision :shell, inline: "wget -O /var/tmp/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar", :privileged => true
    config.vm.provision :shell, inline: "java -jar /var/tmp/jenkins-cli.jar -s http://localhost:8080/ create-job example < /vagrant/jenkins/example_job.xml", :privileged => true
    config.vm.provision :shell, inline: "java -jar /var/tmp/jenkins-cli.jar -s http://localhost:8080/ install-plugin swarm -restart", :privileged => true
    config.vm.provision :shell, inline: "service jenkins restart", :privileged => true
  end

  config.vm.define "jenkins-master-2" do |config|
    config.vm.network "private_network", ip: "192.168.50.12"

    # add repositories
    config.vm.provision :shell, :inline => "apt-get update", :privileged => true
    config.vm.provision :shell, :inline => "apt-get install -y software-properties-common", :privileged => true
    config.vm.provision :shell, :inline => "add-apt-repository ppa:gluster/glusterfs-3.8", :privileged => true
    config.vm.provision :shell, inline: "wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -", :privileged => true
    config.vm.provision :shell, inline: "sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'", :privileged => true
    config.vm.provision :shell, inline: "apt-get update", :privileged => true

    # install jenkins
    config.vm.provision :shell, inline: "apt-get -y install jenkins", :privileged => true
    config.vm.provision :shell, inline: "service jenkins stop", :privileged => true

    # install & mount glusterfs
    config.vm.provision :shell, :inline => "apt-get install -y glusterfs-client", :privileged => true
    config.vm.provision :shell, :inline => "mkdir -p /var/lib/jenkins && sudo mount -t glusterfs 192.168.50.5:/jenkins_home /var/lib/jenkins", :privileged => true
  end

  config.vm.define "loadbalancer" do |config|
    config.vm.network "private_network", ip: "192.168.50.10"

    config.vm.network "forwarded_port", guest: 8080, host: 8080

    config.vm.provision :shell, inline: "sudo apt-get update"
    config.vm.provision :shell, inline: "sudo apt-get -y install haproxy"
    config.vm.provision :shell, inline: "sudo cp /vagrant/haproxy/haproxy.cfg_template /etc/haproxy/haproxy.cfg"
    config.vm.provision :shell, inline: "sudo cp /vagrant/haproxy/haproxy_template /etc/default/haproxy"
    config.vm.provision :shell, inline: "sudo service haproxy restart"
  end

  config.vm.define "jenkins-slave-linux" do |config|
    config.vm.network "private_network", ip: "192.168.50.20"

    config.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "jenkins-swarm-client"
    end
  end

end
