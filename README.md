# jenkins-failover-demo

[![Build Status](https://ci.endocode.com/buildStatus/icon?job=public/jenkins-failover-demo)](https://ci.endocode.com/job/public/jenkins-failover-demo)

Proof of Concept for redundant setup of Jenkins CI 

![alt text](concept.png "implementation idea")

## implemenatation

2 Jenkins masters (1 active, 1 standby) that mount a shared GlusterFS storage behind a HAProxy. Slaves connect via the Swarm plugin and locally running swarm cli.

### run

`vagrant up`

### clean up

`vagrant destroy -f`

### CI run
`vagrant up; ruby status.rb ci; vagrant destroy -f`
