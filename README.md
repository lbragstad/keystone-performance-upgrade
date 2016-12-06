# Upgrade Performance

The objective of this exercise is to perform a rolling upgrade from OpenStack
Newton to the latest master branch, while exposing the deployment to
performance testing. Since we are a week away from Ocata-2, this is effectively
simulating a rolling upgrade from Newton to Ocata.

In Newton, keystone introduced zero-downtime upgrades. The test will start by
continuously authenticating and validating tokens against a single
authentication endpoint backed by two keystone nodes. The performance tests
will continue to run as we take one node out of rotation, upgrade it, and place
it back into rotation. We'll repeat the same process with the other node. We
will let the performance tests run against the latest release before stopping
the test and collecting the results.

This repository contains the scripts used to performance test keystone, which
are simply shell scripts using ApacheBench.

### Infrastructure

* Hardware: [Rackspace Cloud Instance](https://www.rackspace.com/en-us/cloud/servers)
    - 8 vCPUs
    - 30 GB RAM
    - 1.2 TB disk
* Operating System: Ubuntu 16.04 LTS (Xenial Xerus)

### Deployment

Deployed using [OpenStack Ansible](http://docs.openstack.org/developer/openstack-ansible/) using
an [all-in-one installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html).

## Setup

I started by following the developer guide for an [all-in-one
installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html)
making only a couple modifications after laying down the initial infrastructure.

## Stable Newton Install Process

1. Update AIO host `apt-get update; apt-get dist-upgrade; reboot`
2. Get OpenStack Ansible source `git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible; cd /opt/openstack-ansible`
3. Checkout Newton `git checkout stable/newton; git checkout 15.0.0.0b1`
4. Run `scripts/bootstrap-ansible.sh`
5. Run `scripts/bootstrap-aio.sh`
6. Modify `keystone.yml` affinity setting [0]
7. Run `openstack-ansible playbooks/setup-hosts.yml`
8. Run `openstack-ansible playbooks/setup-infrastructure.yml`
9. Run `openstack-ansible playbooks/os-keystone-install.yml`

[0] place the following in `/etc/openstack_deploy/conf.d/keystone.yml`:

```
---
identity_hosts:
  aio1:
    affinity:
      keystone_container: 2
    ip: 172.29.236.100
```

## Benchmarking

The benchmark was run from the utility container provided in the AIO.

1. Confirm you can get a token using `source openrc; openstack token issue`
2. Clone the benchmark repository `git clone https://github.com/lbragstad/keystone-performance-upgrade`
3. Copy the password from `openrc` into `auth.json`
4. Install locust using `easy_install locustio`
5. Run locust using `locust --no-web --clients=4 --hatch-rate=1 --only-summary --host=http://172.29.236.100 --port=5000 --logfile=results/locust.log`

## Upgrade Process

1. Checkout `master`
2. Run `scripts/bootstrap-ansible.sh`
3. Run `openstack-ansible playbooks/os-keystone-install.yml -e keystone_upgrade=True`
