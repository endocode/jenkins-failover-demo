### this gets and show the cluster status in the terminal
# if started with argument "ci" it raises exceptions failed services
# status is gathered via ssh / ping

require 'net/ping'

$ci_mode = false
$storage1_status = false
$storage2_status = false
$haproxy_status = false
$jenkins_master_1 = false
$jenkins_master_2 = false
$jenkins_slave_linux = false
$jenkins_slave_linux_agent = "unknown"

ARGV.each do|a|
    if a == "ci"
        $ci_mode = true
    end
end

def check_hosts
    if up?('192.168.50.5')
        unless `vagrant ssh gluster-server-1 -c "service glusterfs-server status | grep Active" 2>&1`.include? "inactive"
            $storage1_status = true
        else
            $storage1_status = false
        end
    end

    if up?('192.168.50.6')
        unless `vagrant ssh gluster-server-2 -c "service glusterfs-server status | grep Active" 2>&1`.include? "inactive"
            $storage2_status = true
        else
            $storage2_status = false
        end
    end

    if up?('192.168.50.10')
        unless `vagrant ssh loadbalancer -c "service haproxy status | grep Active" 2>&1`.include? "inactive"
            $haproxy_status = true
        else
            $haproxy_status = false
        end
    end

    if up?('192.168.50.11')
        unless `vagrant ssh jenkins-master-1 -c "service jenkins status | grep Active" 2>&1`.include? "inactive"
            $jenkins_master_1 = true
        else
            $jenkins_master_1 = false
        end
    end

    if up?('192.168.50.12')
        unless `vagrant ssh jenkins-master-2 -c "service jenkins status | grep Active" 2>&1`.include? "inactive"
            $jenkins_master_2 = true
        else
            $jenkins_master_2 = false
        end
    end

    if up?('192.168.50.20')
        if `vagrant ssh jenkins-slave-linux -c "ps aux | grep swarm" 2>&1`.include? "swarm-client"
            $jenkins_slave_linux = true
        else
            $jenkins_slave_linux = false
        end

        if `vagrant ssh jenkins-slave-linux -c "tail /tmp/swarm.log" 2>&1`.include? "INFO: Connected"
            $jenkins_slave_linux_agent = "Connected"
        else
            $jenkins_slave_linux_agent = "Disconnected"
        end
    end

end

def up?(host)
    check = Net::Ping::External.new(host,22,1)
    check.ping?
end

def print_status
        system "clear" or system "cls"
    
        puts "------------------------------"
        puts "Services:"
        puts "------------------------------"
        puts "HA Proxy: " + $haproxy_status.to_s
        puts "GlusterFS Server 1: " + $storage1_status.to_s
        puts "GlusterFS Server 2: " + $storage2_status.to_s
        puts "Jenkins Master 1: " + $jenkins_master_1.to_s
        puts "Jenkins Master 2: " + $jenkins_master_2.to_s
        puts "Jenkins Slave Linux: " + $jenkins_slave_linux.to_s

        puts "------------------------------"
        puts "Slaves:"
        puts "------------------------------"
        puts "Jenkins Slave Linux: " + $jenkins_slave_linux_agent
        puts "------------------------------"

        puts "Status from: " + Time.now.to_s
end

def check_status
    unless $jenkins_master_1 or $jenkins_master_2
        raise("Jenkins not up...")
    end
    unless $storage1_status and $storage2_status
        raise("GlusterFS not up...")
    end
    unless $haproxy_status
        raise("HaProxy not up...")
    end
    unless $jenkins_slave_linux
        raise("Jenkins Slave not up...")
    end
    unless $jenkins_slave_linux_agent=="Connected"
        raise("Jenkins Slave not connected...")
    end

    puts "all checks passed"
end

if $ci_mode == true
    puts "CI MODE - checking system status"
        check_hosts
        check_status
else
    while true do
        check_hosts
        print_status
        sleep 10
    end
end