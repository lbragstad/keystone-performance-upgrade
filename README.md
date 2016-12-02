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

- Hardware: [Rackspace OnMetal v2 Large](https://www.rackspace.com/en-us/cloud/servers/onmetal/specs)
- Operating System: Ubuntu 14.04 LTS (Trusty Tahr)

### Deployment

Deployed using [OpenStack Ansible](http://docs.openstack.org/developer/openstack-ansible/) using
an [all-in-one installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html).

## Setup

I started by following the developer guide for an [all-in-one
installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html)
making only a couple modifications after laying down the initial infrastructure.

## Stable Newton Install Process

1. Checkout `stable/newton`
2. Run `scripts/bootstrap-ansible.sh`
3. Run `scripts/bootstrap-aio.sh`
4. Modify `keystome.yml` affinity setting
```
---
identity_hosts:
  aio1:
    affinity:
      keystone_container: 2
    ip: 172.29.236.100
```
5. Run `openstack-ansible playbooks/setup-hosts.yml`
6. Run `openstack-ansible playbooks/setup-infrastructure.yml`
7. Run `openstack-ansible playbooks/os-keystone-install.yml`

## Upgrade Process

1. Checkout `master`
2. Run `scripts/bootstrap-ansible.sh`
3. Run `openstack-ansible playbooks/os-keystone-install.yml -e keystone_upgrade=True`
