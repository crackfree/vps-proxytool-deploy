#! /bin/bash

set -x
host_address=''

base_package='sudo  wget curl     python   python-pip  fail2ban  git   supervisor  iptables gcc autoconf'
extra_package='screen    htop   vim'
special_package='libsodium'

centos_package='chkconfig'
debian_package=''



function iptables_config()
{
	#iptables-configure
	#iptables -A INPUT -p icmp  -s 0/0 -j DROP


	##ping
	iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -j DROP
	iptables -A INPUT -p icmp --icmp-type 0 -s 0/0 -j ACCEPT
	iptables -A OUTPUT -p icmp --icmp-type 0 -s ${host_address} -j DROP
	iptables -A OUTPUT -p icmp --icmp-type 8 -s ${host_address} -j ACCEPT


	#nat
	iptables -t nat -A POSTROUTING  -j MASQUERADE

	iptables-save > /etc/iptables.bak
}


function ocserv_install()
{
	wget https://raw.githubusercontent.com/travislee8964/Ocserv-install-script-for-CentOS-RHEL-7/master/ocserv-install-script-for-centos7.sh
	sh ocserv-install-script-for-centos7.sh
	wget https://raw.githubusercontent.com/jannerchang/Ocserv-install-script-for-CentOS-RHEL-7/master/build-ca.sh
	sh build-ca.sh
	wget https://raw.githubusercontent.com/jannerchang/Ocserv-install-script-for-CentOS-RHEL-7/master/change-to-ca.sh
	bash change-to-ca.sh

	sed   -i 's/$$/$$/g'  /usr/local/etc/ocserv/ocserv.conf
	cd /root
	tar cvf  ocserv-cert.tar  /usr/local/etc/ocserv/ca  
	service ocserv restart
}

 


function finalspeed_install()
{
	##finalspeed
	cd ~
	rm -f install_fs.sh
	wget  http://fs.d1sm.net/finalspeed/install_fs.sh
	chmod +x install_fs.sh
	./install_fs.sh 2>&1 | tee install.log
	chmod +x  /fs/*.sh

	echo 0 3 * * *  sh /fs/restart.sh  >>/etc/crontab
	echo 0 15 * * *  sh /fs/restart.sh  >>/etc/crontab
}



function serverspeed_install()
{	
	cd ~
	wget -N --no-check-certificate https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder-all.sh && bash serverspeeder-all.sh
}


function ruisu()
{
	serverspeed_install
}



function ssr_install()
{
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
}



function debian_install()
{
	apt-get update #/
	#&& apt-get upgrade -y

	#essential
	apt-get install $base_package   -y
	apt-get install $extra_package -y
	apt-get install $debian_package -y
	apt-get install $special_package -y

	#ssh configure
	##ssh time extend
	echo "ClientAliveInterval 60" >>/etc/ssh/sshd_config



	#proxy
	pip install shadowsocks


	ssr_install

	

}




function centos_install()
{
	yum check-update
	yum -y install $base_package
	yum -y install $extra_package


	#ssh configure
	##ssh time extend
	echo "ClientAliveInterval 60" >>/etc/ssh/sshd_config

	#proxy
	pip install shadowsocks

	ssr_install
}



function main()
{
	# if [[  ! host_address ]]; then
	# 	#statements
	# 	echo ERR host_address is not set.
	# 	exit 1
	# fi

	if [[ -f /etc/redhat-release  ]]; then
		#statements
		centos_install
	fi


	if [[ -f /etc/debian_version ]]; then
		#statements
		debian_install
	fi

}




main



set +x






