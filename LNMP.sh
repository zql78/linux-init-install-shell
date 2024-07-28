#!/bin/bash

auto-changesource(){
    cp /etc/apt/sources.list.d/ubuntu.sources /home/zjq/ubuntu.sources.backup
    rm -rf /etc/apt/sources.list.d/ubuntu.sources
    echo "Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" >> /etc/apt/sources.list.d/ubuntu.sources
check=$?
if [ $check = "0" ]; then
echo -e "\033[0;32mchenge ok\033[0m"

fi
}

auto-update(){
    apt update -y
    echo -e "\033[0;32mupdate ok\033[0m"
    apt upgrade -y
    echo -e "\033[0;32mupgrade ok\033[0m"
}

auto-install(){
    apt install nginx -y
    systemctl enable nginx
    apt install mysql-server -y
    systemctl enable mysql
    auto-exporterinstall
}

auto-check(){

    systemctl status nginx | tee $(date '+%Y-%m-%d')-nginx.log
    ngstatuscheck=$?
    systemctl status mysql | tee $(date '+%Y-%m-%d')-mysql.log
    mysqlstatuscheck=$?
    if [ $ngstatuscheck = "0" ] || [ $mysqlstatuscheck = "0" ];then
    echo -e "\033[0;32mcheck ok\033[0m"
    else
    echo -e "\033[0;31something wrong :error code:1 --check failes please connect zjq\033[0m"
    fi

}

auto-exporterinstall(){
    apt install -y git
    dir=/home/zjq/Installationpackage
    [ -d $dir ] && printf "\033[0;32m文件夹存在\033[0m"  || mkdir /home/zjq/Installationpackage
    edir=/opt/prometheus/
    [ -d $edir ] && printf "\033[0;32m文件夹存在\033[0m"  || mkdir /opt/prometheus/
    cd /home/zjq/Installationpackage || exit
    git clone https://github.com/zql78/linux-install.git
    cd /home/zjq/Installationpackage/linux-install || exit
    tar -zxvf node_exporter-1.8.2.linux-amd64.tar.gz
    cd /home/zjq/Installationpackage/linux-install/node_exporter-1.8.2.linux-amd64 || exit
    mv node_exporter /opt/prometheus/node_exporter
    mv LICENSE /opt/prometheus/LICENSE
    cd /opt/prometheus/ || exit
    chmod 777 /opt/prometheus
    echo "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/opt/prometheus/node_exporter

[Install]
WantedBy=multi-user.target

" >> /etc/systemd/system/node_exporter.service

    
    systemctl daemon-reload
    systemctl restart node_exporter | tee /home/zjq/$(date '+%Y-%m-%d')-node_exporter.log
    systemctl enable node_exporter
    echo "    - job_name: 'node-exporter'
    scrape_interval: 15s
    static_configs:
    - targets: ['localhost:9100']
      labels:
        instance: 192.168.0.105" | tee /opt/prometheus/prometheus.yml
    cd /opt/prometheus/ || exit
    systemctl restart node_exporter
    echo -e "\033[0;32mDONE!\033[0m"


}
SMENU(){
echo "----------MENU----------"
echo "1-auto-install"
echo "2-changesource"
echo "3-update&upgrade"
echo "4-exporterinstall"
read -p "please choose number:" nb
if [ $nb = "1" ];then
    auto-install
    elif [ $nb = "2" ];then
    auto-changesource
    elif [ $nb = "3" ];then
    auto-update
    elif [ $nb = "4" ];then
    auto-exporterinstall
fi

}

SMENU
# auto-changesource
# auto-update
# auto-install
# auto-check
# auto-exporterinstall
