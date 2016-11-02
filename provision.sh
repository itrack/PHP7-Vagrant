#!/bin/bash

# yum repo
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://centos7.iuscommunity.org/ius-release.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum update -y
yum upgrade -y

# memcached
yum install memcached
systemctl enable memcached
systemctl start memcached

# redis
yum install -y redis
systemctl enable redis
systemctl start redis

# mysql
rpm -ivh https://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm
yum install -y mysql-community-server
systemctl enable mysqld
systemctl start mysqld

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

# nginx
yum install -y nginx
rm -rf /etc/nginx/conf.d
ln -s /vagrant/nginx/conf.d/ /etc/nginx
sed -i "s/sendfile[ ][ ]*on/sendfile off/" /etc/nginx/nginx.conf
ln -s /vagrant/www/ /var/www
#systemctl enable nginx
#systemctl start nginx

# php 7
yum --enablerepo=remi install -y php70-php-cli php70-php-fpm php70-php-gd php70-php-intl php70-php-json php70-php-mbstring php70-php-mcrypt php70-php-mysqlnd php70-php-opcache php70-php-pdo php70-php-xml php70-php-pecl-zip php70-php-pecl-memcached
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/opt/remi/php70/php.ini
systemctl enable php70-php-fpm
systemctl start php70-php-fpm
ln -s /usr/bin/php70 /usr/bin/php

# composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# vim
yum install -y vim
sed -i -e "\$a\ " /etc/vimrc
sed -i -e "\$asyntax on" /etc/vimrc
sed -i -e "\$aset nu" /etc/vimrc

# utilities
yum install -y wget htop net-tools git certbot unzip

# phpmyadmin
mkdir /var/www-tools
wget https://files.phpmyadmin.net/phpMyAdmin/4.6.4/phpMyAdmin-4.6.4-all-languages.zip
unzip phpMyAdmin-4.6.4-all-languages.zip
rm -f phpMyAdmin-4.6.4-all-languages.zip
mv phpMyAdmin-4.6.4-all-languages /var/www-tools/phpMyAdmin
cat <<EOT >> /var/www-tools/phpMyAdmin/config.inc.php
<?php
\$cfg['Servers'][1]['host'] = 'localhost';
\$cfg['Servers'][1]['connect_type'] = 'tcp';
\$cfg['Servers'][1]['compress'] = false;
\$cfg['Servers'][1]['AllowNoPassword'] = true;
EOT

# disable firewall
systemctl disable firewalld
systemctl stop firewalld

# disable selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
reboot
