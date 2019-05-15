# Host Vars

these *.yaml files defines specific sections for all hosts, which are defined here. 
And have to match the unique hostname as utilized in the playbooks. These settings will overwrite the variables defines for the group!

So the same sections as for groups apply.

## Use cases

The main use case is for now, if one of the hosts need special network settings, for example if it's supposed to work as a public gateway node and
so exposes an additions bridge, as can be seen in this example.

Or to specify docker labels for the given host.

```.env
docker_node_labels:
  kvm: "true"
  elasticdb: "true"


network:

  ##
  # this contains the general network configuration, which should be adapted to local host needs
  netplan:
    configuration:
      network:
        ethernets:
          enp3s0f0: {}
          enp3s0f1: {}
          enp4s0f0: {}
          enp4s0f1: {}

          ##
          # cluster internal network
          ens2f0:
            dhcp4: true

          ##
          # public facing network configuration
          ens2f1:
            dhcp4: false

        bonds:
          bond0:
            parameters:
              mode: 802.3ad
              lacp-rate: fast
              mii-monitor-interval: 50
            interfaces:
              - enp3s0f0
              - enp3s0f1
              - enp4s0f0
              - enp4s0f1
            mtu: 9000
            dhcp4: false

        vlans:
          # delegate to the bridges
          vlan.prod:
            id: 30
            link: bond0
            dhcp4: false
            dhcp6: false

          # delegate to the bridges
          vlan.test:
            id: 31
            link: bond0
            dhcp4: false
            dhcp6: false

          # delegate to the bridges
          vlan.nas:
            id: 111
            link: ens2f0
            dhcp4: false
            dhcp6: false

          # delegate to the bridges
          vlan.nvme:
            id: 110
            link: ens2f0
            dhcp4: false
            dhcp6: false

        # defines brigdes for KVM based interfaces
        bridges:

          # bridge to the public outside network to be utilized by this node
          br.public:
            dhcp4: true
            interfaces:
              - ens2f1

          # production cluster resides in this network
          br.prod:
            interfaces:
              - vlan.prod
            dhcp6: false
            dhcp4: true
            dhcp-identifier: mac

          # test cluster resides in this network
          br.test:
            interfaces:
              - vlan.test
            dhcp4: true
            dhcp6: false
            dhcp-identifier: mac

          # shared services reside in this network
          br.nvme:
            interfaces:
              - vlan.nvme
            dhcp4: true
            dhcp6: false
            dhcp-identifier: mac
          # data access resides in this network
          br.nas:
            interfaces:
              - vlan.nas
            dhcp4: true
            dhcp6: false
            dhcp-identifier: mac
```
