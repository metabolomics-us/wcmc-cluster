#drives

This role configured and partions your harddrive accordingly to the standard of this installation method.

You can configure this with variables to define the split, etc.


```.env
##
# configuration of your storage backends
storage:

  ##
  # here we will store all KVM related content.
  #
  device: "/dev/nvme0n1"

  ##
  # how much storage do you want to allocated to the KVM storage
  split_kvm:
    begin: 1%
    end: 60%

  ##
  # how much storage do you want to allocated for gluster
  # we really recommend 10GB/s of faster networks for this!
  split_gluster:
    begin: 61%
    end: 99%
```