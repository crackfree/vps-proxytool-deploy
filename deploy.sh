#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

set -x

host_address=""

base_package='sudo  wget curl    python   python-pip  fail2ban  git   supervisor  iptables gcc autoconf cron'
extra_package='screen    htop   vim'
special_package=''

centos_package='chkconfig yum-cron python-m2crypto'
debian_package="unattended-upgrades build-essential python-m2crypto"





#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt-get'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt-get'
	else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        ver3='x64'
    else
        ver3='x32'
    fi
}


function Get_System_Info()
{

	Get_Dist_Name
	#安装相应的软件
	if [ "$DISTRO" == "CentOS" ];then
		yum install -y redhat-lsb curl net-tools
	elif [ "$DISTRO" == "Debian" ];then
		#apt-get update
		apt-get install -y lsb-release curl
	elif [ "$DISTRO" == "Ubuntu" ];then
		# apt-get update
		apt-get install -y lsb-release curl
	else
		echo "一键脚本暂时只支持centos，ubuntu和debian的安装，其他系统请选择手动安装"
		exit 1
	fi



	release=$DISTRO
	#发行版本
	if [ "$release" == "Debian" ]; then
		ver1str="lsb_release -rs | awk -F '.' '{ print \$1 }'"
	else
		ver1str="lsb_release -rs | awk -F '.' '{ print \$1\".\"\$2 }'"
	fi
	ver1=$(eval $ver1str)
	#ver11=`echo $ver1 | awk -F '.' '{ print $1 }'`

	#内核版本
	ver2=`uname -r`	
}








#install packages
function package_install()
{

	packageslist_update

	#install base_package
	for item in ${base_package}; do
		${PM} -y install $item    2>>deploy.err  1>/dev/null
		# sleep 3
	done
	del item

	#install extra_package
	for item in ${extra_package}; do
		${PM} -y install $item  2>>deploy.err  1>/dev/null
		# sleep 3
	done
	del item



	#install special_package
	for item in ${special_package}; do
		${PM} -y install $item  2>>deploy.err  1>/dev/null
		# sleep 3
	done
	del item


	# libsodium_install	

	ss_install

	ssr_install

	ocserv_install

	serverspeed_install

	# finalspeed_install

	case $DISTRO in
		Ubuntu )
		debian_install
			;;
		Debian )
		debian_install
			;;
		CentOS )
		centos_install
			;;
	esac


}


function packageslist_update()
{
	if [ $DISTRO -eq "Ubuntu" -o $DISTRO -eq "Debian" :]; then
		${PM} update -y

	elif [[ "DISTRO"x = "CentOS"x ]]; then
		${PM} check-update -y
	else
		echo "packageslist_update failed."
	fi
}




function debian_install()
{
	:
}




function centos_install()
{
	:
}



#each  package install

function ocserv_install()
{

	case ${DISTRO} in
		Ubuntu )
		
			;;
		Debian )
		
			;;
		CentOS )
		centos_ocserv_install
			;;
	esac


}


function centos_ocserv_install()
{
	wget https://raw.githubusercontent.com/travislee8964/Ocserv-install-script-for-CentOS-RHEL-7/master/ocserv-install-script-for-centos7.sh
	sh ocserv-install-script-for-centos7.sh
	wget https://raw.githubusercontent.com/jannerchang/Ocserv-install-script-for-CentOS-RHEL-7/master/build-ca.sh
	sh build-ca.sh
	wget https://raw.githubusercontent.com/jannerchang/Ocserv-install-script-for-CentOS-RHEL-7/master/change-to-ca.sh
	bash change-to-ca.sh
	# sed   -i 's/$$/$$/g'  /usr/local/etc/ocserv/ocserv.conf
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




function ss_install()
{
	echo 'function ss_install()'
	pip install shadowsocks
}

function ssr_install()
{
	##shadowsocks-rss	
	cd /opt/
	git clone -b manyuser https://github.com/breakwa11/shadowsocks.git
	cd  /opt/shadowsocks/shadowsocks
	ln -s  `pwd`/server.py   /usr/bin/ssrserver
}




function libsodium_install()
{	
	
	${PM} -y install libsodium

	if [[ $? -ne '0' ]]; then
		cd ~
		wget https://github.com/jedisct1/libsodium/releases/download/1.0.10/libsodium-1.0.10.tar.gz
		tar xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
		./configure && make -j2 && make install
		ldconfig
	fi
	

}
##end each package install



#system config

function system_config()
{
	echo 'function system_config()'

	iptables_config


	#ssh configure
	##ssh time extend
	echo "ClientAliveInterval 60" >>/etc/ssh/sshd_config

	case ${DISTRO} in
		Ubuntu )
		debian_config
			;;
		Debian )
		debian_config
			;;
		CentOS )
		centos_config
			;;
	esac

}



function debian_config()
{
	echo 'function debian_config()'
	service cron start
}


function centos_config()
{
	chkconfig --level  345  crond on
	service cron start
	service crond start
}



function iptables_config()
{
	echo 'function iptables_config()'
	#iptables-configure
	#iptables -A INPUT -p icmp  -s 0/0 -j DROP


	##ping
	iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -j DROP
	iptables -A INPUT -p icmp --icmp-type 0 -s 0/0 -j ACCEPT
	# iptables -A OUTPUT -p icmp --icmp-type 0 -s ${host_address} -j DROP
	# iptables -A OUTPUT -p icmp --icmp-type 8 -s ${host_address} -j ACCEPT
	
    
	#nat
	iptables -t nat -A POSTROUTING  -j MASQUERADE

	iptables-save > /etc/iptables.bak
}
##end system config



function main()
{
	# if [[  ! host_address ]]; then
	# 	#statements
	# 	echo ERR host_address is not set.
	# 	exit 1
	# fi

	Get_System_Info


	echo "================================================="
	echo "操作系统：$release "
	echo "发行版本：$ver1 "
	echo "内核版本：$ver2 "
	echo "位数：$ver3 "
	echo "================================================="

	package_install


	system_config



}




main



set +x
