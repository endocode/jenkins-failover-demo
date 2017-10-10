### This is an example how to trigger the manual failover
# logic: find out which master is active, disable it, enable the other one

jenkins_master_1 = false
jenkins_master_2 = false

puts "find out which is the current active master..."

unless `vagrant ssh jenkins-master-1 -c "service jenkins status | grep Active" 2>&1`.include? "inactive"
    jenkins_master_1 = true
else
    jenkins_master_1 = false
end

unless `vagrant ssh jenkins-master-2 -c "service jenkins status | grep Active" 2>&1`.include? "inactive"
    jenkins_master_2 = true
else
    jenkins_master_2 = false
end

puts "Performing a Switch..."
if jenkins_master_1
    puts "   - Master 1 is currently active"
    puts "   - Making master 2 active"
    `vagrant ssh jenkins-master-1 -c "sudo service jenkins stop" 2>&1`
    `vagrant ssh jenkins-master-2 -c "sudo chown -R jenkins:jenkins /var/lib/jenkins/" 2>&1`
    `vagrant ssh jenkins-master-2 -c "sudo service jenkins start" 2>&1`
    
end
if jenkins_master_2
    puts "   - Master 2 is currently active"
    puts "   - Making master 1 active"
    `vagrant ssh jenkins-master-2 -c "sudo service jenkins stop" 2>&1`
    `vagrant ssh jenkins-master-1 -c "sudo chown -R jenkins:jenkins /var/lib/jenkins/" 2>&1`
    `vagrant ssh jenkins-master-1 -c "sudo service jenkins start" 2>&1`

end
puts "Switching done!"