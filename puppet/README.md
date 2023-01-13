# Bootstrap
wget https://apt.puppet.com/puppet7-release-$(lsb_release -c -s).deb
sudo apt install ./puppet7-release-$(lsb_release -c -s).deb
sudo apt update
sudo apt install puppet-agent r10k

( Clone this repo with --recurse-submodules )

## eyaml setup
sudo gem install hiera-eyaml
sudo mkdir /etc/puppetlabs/puppet/keys
eyaml createkeys
sudo cp keys/private_key.pkcs7.pem /etc/puppetlabs/puppet/keys/puppet_eyaml.key
sudo cp keys/public_key.pkcs7.pem /etc/puppetlabs/puppet/keys/puppet_eyaml.crt
rm -rf ./keys

## apply code
sudo bash /root/hyper.equipment/puppet/scripts/run-puppet.sh



# Manual Files

`/opt/compose/calckey/volumes/config/default.yml`:
sourced from /root/calckey_config.yml
```yml
a lot of stuff
```
