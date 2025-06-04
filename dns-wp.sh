#!/bin/bash

#Warna
Green='\033[0;32m' 
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Script harus dijalankan sebagai root." >&2
  exit 1
fi

echo -e "${Green}Otomatisasi Konfigurasi DNS & Wordpress by Rullabcd${NC}"
echo "Masukan konfigurasi DNS & Wordpress"
read -p "Masukan nama domain, ex: (rullabcd.com): " domain
read -p "Masukan IP server, ex: (192.168.1.128): " ip
read -p "Masukan user database, ex: (rullabcd): " userdb
read -p "Masukan nama database, ex: (wordpress): " namedb
read -sp "Masukan password database, ex: (siswasiswa): " passdb

host=$( echo $ip | cut -d '.' -f4 ) # simpan ip oktet ke-4
pathforward="/etc/bind/$domain"
pathreverse="/etc/bind/$domain.reverse"
pathnamed="/etc/bind/named.conf.local"
reversenetid=$( echo $ip | awk -F '.' '{print $3"."$2"."$1}') # simpan ip oktet ke-3.2.1

#Update Repository
echo -e "${Green}Update Repository...${NC}"
apt update && apt upgrade -y
apt install wget curl -y

#Install bind9
echo -e "${Green}Install bind9...${NC}"
apt install bind9 bind9utils bind9-doc -y

#Copy zone bind9
echo -e "${Green}Copy zone bind9...${NC}"
cp /etc/bind/db.local $pathforward
cp /etc/bind/db.127 $pathreverse

#Konfigurasi forward 
echo -e "${Green}Konfigurasi forward zone...${NC}"
sed -i "s/localhost/$domain/g" $pathforward
sed -i "s/127.0.0.1/$ip/g" $pathforward
sed -i '$d' $pathforward
echo "www IN  A	$ip" >> $pathforward

#Konfigurasi reverse zone
echo -e "${Green}Konfigurasi reverse zone...${NC}"
sed -i "s/localhost/$domain/g" $pathreverse
sed -i '/PTR/d' $pathreverse
echo "$host	IN	PTR	www.$domain." >> $pathreverse

#Konfigurasi named.conf.local
echo -e "${Green}Konfigurasi named.conf.local...${NC}"
echo "" >> $pathnamed
echo "zone \"$domain\" {" >> $pathnamed
echo "	type master;" >> $pathnamed
echo "	file \"$pathforward\";" >> $pathnamed
echo "};" >> $pathnamed

echo "" >> $pathnamed
echo "zone \"$reversenetid.in-addr-arpa\" {" >> $pathnamed
echo "	type master;" >> $pathnamed
echo "	file \"$pathreverse\";" >> $pathnamed
echo "};" >> $pathnamed

#Restart bind9
echo -e "${Green}Restart bind9...${NC}"
systemctl restart bind9

#Konfigurasi resolvconf
echo -e "${Green}Konfigurasi resolvconf...${NC}"
sed -i "s/127.0.0.53/$ip/g" /etc/resolv.conf

#Install LAMP
echo -e "${Green}Install LAMP...${NC}"
apt install -y apache2 libapache2-mod-php mariadb-server php php-{mysql,xml,curl,gd,mbstring,zip}

#Konfigurasi Database
echo -e "${Green}Konfigurasi Database...${NC}"
mysql -u root -e "CREATE DATABASE $namedb;"
mysql -u root -e "CREATE USER '$userdb'@'localhost' IDENTIFIED BY '$passdb';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $namedb.* TO '$userdb'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

#Install wordpress
echo -e "${Green}Install wordpress...${NC}"
wget -O /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf /tmp/latest.tar.gz -C /var/www/
rm /tmp/latest.tar.gz

# Konfigurasi apache
echo -e "${Green}Konfigurasi apache...${NC}"
cat << EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin root@localhost
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/wordpress

    <Directory /var/www/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/wp.error.log
    CustomLog \${APACHE_LOG_DIR}/wp.access.log combined
</VirtualHost>
EOF

#Aktifkan site & restart apache
echo -e "${Green}Aktifkan site & restart apache...${NC}"
chown -R www-data:www-data /var/www/wordpress
a2dissite 000-default
a2ensite wordpress
systemctl restart apache2

echo -e "${Green}Konfigurasi DNS & Wordpress Selesai${NC}"
echo ""
echo "Domain: $domain"
echo "IP: $ip"
echo "User Database: $userdb"
echo "Password Database: $passdb"
echo "Database: $namedb"
