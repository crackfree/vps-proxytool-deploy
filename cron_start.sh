#!  /bin/bash

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

set -x

# function check_start()
# {
# 	#0 is not start
# 	if [[  -z $( ps aux | grep  $1 | grep -v 'grep' ) ]]; then
# 		echo 0;
# 		return 0;
# 	else
# 		$2
# 	fi

# }




# check_start  'dnscrypt-wrapper'    '/usr/local/sbin/dnscrypt-wrapper --resolver-address=8.8.8.8:53 --listen-address=0.0.0.0:55553 \
#                     --provider-name=2.dnscrypt-cert.donotngng.com \
#                     --crypt-secretkey-file=/home/dns/1.key --provider-cert-file=/home/dns/1.cert  -d'


# check_start  'supervisord'  'supervisord &'

# check_start 'fs.jar'  '/fs/restart.sh  &'
iptables-restore   /etc/iptables.bak >>  /tmp/loglog
ip6tables-restore /etc/ip6tables.bak >> /tmp/loglog

#sudo iptables -A INPUT -p icmp   -j DROP
#sudo iptables -A INPUT -p tcp  --dport 62222  -j DROP
#sudo ip6tables -A INPUT -p icmp -j DROP
#sudo ip6tables -A INPUT -p tcp --dport 62222 -j DROP
#sudo iptables-save

function check_start()
{
	#0 is not start
	if [[  -z $( ps aux | grep  $1 | grep -v 'grep' ) ]]; then
		echo 0;
		return 0;
	fi

}


# if [[   -n $(check_start dnscrypt-wrapper)  ]]; then
# 	#statements
# 	sudo -u nobody /usr/local/sbin/dnscrypt-wrapper --resolver-address=8.8.8.8:53 --listen-address=0.0.0.0:55553 --provider-name=2.dnscrypt-cert.donotngng.com --crypt-secretkey-file=/1.key --provider-cert-file=/1.cert -d

# fi


if [[   -n $(check_start supervisord)  ]]; then
	#statements
	supervisord &
fi


if [[   -n $(check_start fs.jar)  ]]; then
	#statements
	bash /fs/start.sh &
fi



set +x  
