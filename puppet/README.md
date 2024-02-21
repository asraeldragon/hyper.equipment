# Bootstrap
```sh
wget https://apt.puppet.com/puppet7-release-$(lsb_release -c -s).deb
sudo apt install ./puppet7-release-$(lsb_release -c -s).deb
sudo apt update
sudo apt install puppet-agent r10k
git clone --recurse-submodules $THIS_REPO_URL
```

## eyaml setup
```sh
sudo gem install hiera-eyaml
sudo mkdir /etc/puppetlabs/puppet/keys
```

(If this is the first time running the repo, or there's no backup)
```
eyaml createkeys
sudo cp keys/private_key.pkcs7.pem /etc/puppetlabs/puppet/keys/puppet_eyaml.key
sudo cp keys/public_key.pkcs7.pem /etc/puppetlabs/puppet/keys/puppet_eyaml.crt
rm -rf ./keys
```

## apply code
```sh
sudo bash $REPO_LOCATION/puppet/scripts/run-puppet.sh
```

## Login to Docker then apply again
```sh
docker login
sudo bash $REPO_LOCATION/puppet/scripts/run-puppet.sh
```
