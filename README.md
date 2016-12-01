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

Hardware: [Rackspace OnMetal v2 Large](https://www.rackspace.com/en-us/cloud/servers/onmetal/specs)
  - RAM: 128 GB
  - Disk: 800 GB
Operating System: Ubuntu 14.04 LTS (Trusty Tahr)

### Deployment

Deployed using [OpenStack Ansible](http://docs.openstack.org/developer/openstack-ansible/) using
an [all-in-one installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html).

## Setup

I started by following the developer guide for an [all-in-one
installation](http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html)
making only a couple modifications after laying down the initial infrastructure.

By default, the all-in-one installation provides a single container per service.
This is to save resources when using the same setup in gate jobs. In order for
us to test the upgrade scenario outlined above, we will need to make sure we
have more than one keystone node deployed.

After executing `# scripts/run-playbooks.sh`, I modified `/etc/openstack_deploy/conf.d/keystone.yml`
to contain the following:

```
---
identity_hosts:
  aio1:
    affinity:
      keystone_container: 2
    ip: 172.29.236.100
```

Next, I had to run a specific playbook to ensure the infrastructure modeled the new
affinity count:

```
# cd /opt/openstack-ansible/
# openstack-ansible playbooks/lxc-containers-create.yml
```

We can confirm we have an additional keystone container with an `lxc-ls`.
After that we can rerun the HA Proxy installation playbook so that
authentication is routed to both containers.

```
# openstack-ansible playbooks/haproxy-install.yml
```

HA Proxy should now be able to route traffic to both nodes. Our last step in
setting up the initial deployment is rerunning the os_keystone role to ensure
the new container is installed with stable/newton.

```
# openstack-ansible playbooks/os-keystone-install.yml
```
