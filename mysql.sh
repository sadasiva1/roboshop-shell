curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
dnf module disable mysql -y

yum install mysql-community-server -y

systemctl enable mysqld
systemctl restart mysqld

touch /tmt/root-pass-sql
sed -i -e "1 c ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" /tmt/root-pass-sql
DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')

#cat /tmp/root-pass-sql | mysql --connect-expired-password -uroot -p"h,6YikQmv!oX"

