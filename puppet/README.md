# Bootstrap
wget https://apt.puppet.com/puppet7-release-$(lsb_release -c -s).deb
sudo apt install ./puppet7-release-$(lsb_release -c -s).deb
sudo apt update
sudo apt install puppet-agent r10k

( get a copy of this repo and CD into it, into puppet dir )
sudo r10k puppetfile install -v --puppetfile=Puppetfile --moduledir=/etc/puppetlabs/code/modules

sudo /opt/puppetlabs/bin/puppet apply --config puppet.conf --modulepath /etc/puppetlabs/code/modules:site site.pp
