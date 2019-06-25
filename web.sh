#!/bin/bash
#ATUALIZANDO E INSTALANDO AS COISAS
sudo apt -y update
sudo apt -y install php-curl php-gd php-mbstring php-xml php-xmlrpc apache2 php libapache2-mod-php php-mysql
#MODIFICAÇÕES NO APACHE
sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf
sudo a2dissite 000-default.conf
sudo systemctl stop apache2.service
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
#INSTALANDO WORDPRESS
ip_banco="${IPBD}"
usuario="${USER}"
senha="${PASS}"
wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
sudo mv wordpress /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/
cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
   ServerAdmin admin@example.com
   DocumentRoot /var/www/html/wordpress/
   ServerName example.com
   ServerAlias www.example.com
   <Directory /var/www/html/wordpress/> 
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
   </Directory>
   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined 
</VirtualHost>
EOF
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
#CONFIGURANDO BD DO WORDPRESS
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/wp_admin/g" /var/www/html/wordpress/wp-config.php 
sudo sed -i "s/password_here/root/g" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/localhost/$ip_banco/g" /var/www/html/wordpress/wp-config.php
## ALTERANDO A LINGUAGEM PARA PORTUGUES BRASILEIRO
sudo sed -i "s/\$language = ''/\$language = 'pt_BR'/" /var/www/html/wordpress/wp-admin/install.php
sudo echo "define('WPLANG', 'pt_BR');" >> /var/www/html/wordpress/wp-config.php
wget https://github.com/wastsonbaia/trabalhofinalamazon/blob/master/languages.tar.gz
tar -zxf languages.tar.gz
rm languages.tar.gz
sudo mv languages /var/www/html/wordpress/wp-content/languages
## ALTERANDO A VARIAVEL STEP PARA PASSAR IR PARA A TELA DE LOGIN
n=`grep -n '$step =' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d :`
sed -i ""$n"s/: 0;/: 2;/" /var/www/html/wordpress/wp-admin/install.php
## ALTERANDO AS CONFIGURACOES DO USUÁRIO
aux=`grep -n '$weblog_title[[:blank:]]*=' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d ":"`
n=`echo $aux | cut -f 2 -d " "`
sed -i ""$n"s/: '';/: 'Wastson';/" /var/www/html/wordpress/wp-admin/install.php
aux=`grep -n '$user_name[[:blank:]]*=' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d ":"`
n=`echo $aux | cut -f 2 -d " "`
sed -i ""$n"s/: '';/: '"$usuario"';/" /var/www/html/wordpress/wp-admin/install.php
n=`grep -n '$admin_password[[:blank:]]*=' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d :`
sed -i ""$n"s/: '';/: '"$senha"';/" /var/www/html/wordpress/wp-admin/install.php
n=`grep -n '$admin_password_check[[:blank:]]*=' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d :`
sed -i ""$n"s/: '';/: '"$senha"';/" /var/www/html/wordpress/wp-admin/install.php
aux=`grep -n '$admin_email[[:blank:]]*=' /var/www/html/wordpress/wp-admin/install.php | cut -f 1 -d ":"`
n=`echo $aux | cut -f 2 -d " "`
sed -i ""$n"s/: '';/: 'admin@email.com';/" /var/www/html/wordpress/wp-admin/install.php
