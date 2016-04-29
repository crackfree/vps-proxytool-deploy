#! /bin/bash
host_address=

sudo apt-get update && apt-get upgrade -y
#essential
sudo apt-get install  sudo screen    htop   vim  chkconfig  python   python-pip  fail2ban  git   supervisor  iptables  -y
sudo apt-get install gcc autoconf -y

#ssh configure
##ssh time extend
echo "ClientAliveInterval 60" >>/etc/ssh/sshd_config



#proxy
pip install shadowsocks


##shadowsocks-rss
apt-get install m2crypto git build-essential  -y
cd ~
wget https://github.com/jedisct1/libsodium/releases/download/1.0.10/libsodium-1.0.10.tar.gz
tar xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
./configure && make -j2 && make install
ldconfig


cd /opt/
git clone -b manyuser https://github.com/breakwa11/shadowsocks.git
cd  /opt/shadowsocks/shadowsocks
ln -s  `pwd`/server.py   /usr/bin/ssrserver




##finalspeed
cd ~
rm -f install_fs.sh
wget  http://fs.d1sm.net/finalspeed/install_fs.sh
chmod +x install_fs.sh
./install_fs.sh 2>&1 | tee install.log
chmod +x  /fs/*.sh

echo 0 3 * * *  sh /fs/restart.sh  >>/etc/crontab
echo 0 15 * * *  sh /fs/restart.sh  >>/etc/crontab


#iptables-configure
#iptables -A INPUT -p icmp  -s 0/0 -j DROP
##ping
iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -j DROP
iptables -A INPUT -p icmp --icmp-type 0 -s 0/0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -s ${host_address} -j DROP
iptables -A OUTPUT -p icmp --icmp-type 8 -s ${host_address} -j ACCEPT

iptables-save > /etc/iptables.bak






