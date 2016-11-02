# PHP7-Vagrant

Setting up a local web develop environment on Centos 7

Features:
- PHP 7
- MySQL 5.6
- Nginx 1.10
- phpMyAdmin 4.6.4
- Composer
- Let's Encrypt
- HTop
- GIT

# installation
1. clone the repo  
2. run "vagrant up" in command line  
3. edit your hosts file add two lines:  
tool.dev    192.168.33.10  
app.dev     192.168.33.10
4. "vagrant reload"

# usage
1. http://tool.dev/phpMyAdmin to phpMyAdmin
2. http://app.dev to your project home (web root is set to "share/www/", you can change it in "share/nginx/conf.d/vhosts.conf")  

# mysql
root password is empty