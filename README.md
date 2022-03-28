# Raspberry Pi deployment guide
## Bootstrapping
- Download the latest Raspberry Pi OS lite image from https://www.raspberrypi.org/downloads/ and extract it to an SD card using etcher or get the Raspberry Pi Imager and create use that.
- Once the SD card has been set up, create an empty file called ssh without any file extension in the root of the boot partition.
- Put the sd card into the raspberry and power it on.
- Connect to the pi with user pi and user raspberry to verify that the installation worked. Disconnect again.
- Open hosts and add a new host entry for the raspberry. Set ansible_hosts for the entry to the target IP address, not the current one.
- Open wsl and generate an ssh key pair for ansible and (if it doesn't exist yet) a key pair for interactive ssh logons
```
ssh-keygen -t ed25519 -f ~/.ssh/ansible_rsa -N ""
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

- Mount the ansible playbook folder with metadata support (see https://devblogs.microsoft.com/commandline/chmod-chown-wsl-improvements/)
```
sudo mkdir /mnt/ansible
sudo mount -t drvfs [Deployment scripts folder] /mnt/ansible -o metadata
```

- Run the raspi-bootstrap runbook to create a user for ansible.
```
cd /mnt/ansible
ansible-playbook raspi-bootstrap.yml --ask-pass --extra-vars 'ansible_user=pi target=[ansible host name] ansible_host=[current IP] target_ip=[target IP]'
```
- Verify that the setup succeeded by running `ansible [ansible host name] -m setup`

## Setup
- Check the variables and list of users to create in  `group_vars/raspi.yml`
- Run the playbook
```
sudo mkdir /mnt/ansible
sudo mount -t drvfs [Deployment scripts folder] /mnt/ansible -o metadata
cd /mnt/ansible
ansible-playbook raspi.yml
```