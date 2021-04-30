#!/bin/bash

    DIR=`pwd`
    echo " Preparing enviroment for  Switch and UI installation"
    yum -y install epel-release
    yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    yum -y install centos-release-scl
    yum clean expire-cache
    yum -y install libnetfilter_conntrack monit postgresql12 postgresql12-devel wget lzma openssl-devel xz-devel gcc libjpeg-turbo-devel ntp python-devel tcpdump wireshark make bzip2-devel sqlite-devel zip expect telnet git python3 python3-devel python3-pip
    # install php and prerequisites for web ui
    yum -y install https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
    yum -y install httpd  mod_xsendfile lzma openssl-devel xz-devel wget libXtst php56w php65w-opcache php56w-pgsql php56w-gd php56w-mbstring
    ln -s /usr/pgsql-12/bin/pg_config /usr/bin/pg_config
    ln -s /usr/pgsql-12/bin/psql /usr/bin/psql
    if [ ! -f /usr/bin/wget ]; then
	yum -y install wget
    fi
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/GMT /etc/localtime
    echo "enabling and starting network time services"
    systemctl start ntpd
    systemctl enable ntpd
    user=denovo
    id -u $user &>/dev/null|| useradd $user -d /opt/$user
    chmod 755 /opt/$user
    if [ ! -d /opt/$user ]; then
	mkdir /opt/$user
	chmod 755 /opt/$user
	chown -R $user:$user /opt/$user
    fi
    #echo "enter password for accessing stash.denovolab.com:"
    #read -s password
    #pass=$password
    #sleep 3
    cd /opt
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/ta/class4-alert---valentin.git /opt/$user/dnl_alerts
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/pyt/class-4-data-import.git /opt/$user/dnl_data_import
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/ig/dnl_invoice_generator.git /opt/$user/dnl_invoice_generator
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/ds/did-billing.git /opt/$user/dnl_did_billing
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/pyt/monitoring.git /opt/$user/dnl_monitoring
    git clone http://docker:iZhU9L4ajhG8QKk@stash.denovolab.com/scm/clas4-v5-rel/class4-v5.0.git /opt/class4-v5-rel

    cd /opt/class4-v5-rel
    if [ ! -d /opt/$user/web ]; then
    mkdir /opt/$user/web
    fi
    cp -R web /opt/$user/web/
    cp -R etc /opt/$user/web/
    cp -R download /opt/$user/web/
    cp -R script /opt/$user/web/
    cp -R backend/dnl_db_writer /opt/$user/
    cp -R backend/dnl_livecall /opt/$user/
    cp -R backend/dnl_memdb /opt/$user/
    cp -R backend/dnl_sip_proxy /opt/$user/
    cp -R backend/dnl_softswitch /opt/$user
    cp -R backend/dnl_tools /opt/$user
    cp -R backend/dnl_web_helper /opt/$user
    cd $DIR
    mkdir /opt/$user/dnl_data_import/logs
    mkdir /opt/$user/dnl_monitoring/logs
    chown -R $user:$user /opt/$user
    if [ -d /opt/$user/web ];then
	cd /opt/$user/web/web
	/opt/$user/web/web/chmod.sh
    fi
    /usr/bin/pip3 install -r/opt/$user/dnl_did_billing/requirements.txt
    echo "inserting public ip into softswitch config"
    ip=$(ip route get 1 | awk '{print $NF;exit}')
    echo "your public ip is:" $ip
    sed -i -e 's/lrn_local_ip =/& '$ip'/g' /opt/denovo/dnl_softswitch/conf/dnl_softswitch.conf
    sed -i -e 's/license_ip =/& '$ip'/g' /opt/denovo/dnl_softswitch/conf/dnl_softswitch.conf
    echo "Setting ip_forward and iptables for the proxy media"
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    modprobe nf_conntrack
    cd $DIR
    echo $DIR
    echo "installing service files "
    chown -R root:root denovo_systemd_init_scripts
    chmod 644 denovo_systemd_init_scripts/sudoers.d/denovo
#    cp -R denovo_systemd_init_scripts/dnl_data_import.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_alerts.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_fraud.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_alert_rules.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_did_billing_server.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_did_billing_invoice.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_invoice_autoinvoice.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_invoice_server.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_monitoring.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_web_helper.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_livecall.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_pcap_gunicorn.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_pcap_loader.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_pcap_parser.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_rt_index.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_softswitch.service /etc/systemd/system
#    cp -R denovo_systemd_init_scripts/dnl_tools.service /etc/systemd/system
#    cd /etc/systemd/system

    if [ -d /opt/$user/web ]; then
	echo "preparing httpd for a webUI"
	cp -R /opt/denovo/web/etc/denovo.conf /etc/httpd/conf.d/
	cd $DIR
	chown -R root:root php.ini
	cp -R php.ini /etc/php.ini
#	systemctl enable httpd
#	systemctl start httpd
    fi
echo " Done ! "
