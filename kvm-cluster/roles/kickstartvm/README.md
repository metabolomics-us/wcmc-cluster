#kickstartvm

this role will download and configure a kickstart image for you, which will be utilized
to install all virtual machines.

Right now we only support ubuntu 18.04 LTS

##Authentification

by default the root account will be allowed to login over SSH, as well as the user 'wohlgemuth',
with the configured pub ssh key, from the current users home directory.

So obviosuly this is far from perfect!