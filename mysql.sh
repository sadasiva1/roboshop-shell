echo -e "\e[33mMySQL Repo Downloading\e0m"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
if [ $? -eq 0 ]; then
   echo SUCCESS
else
  echo FAILURE
fi

echo Disable MySQL 8 Version Repo
dnf module disable mysql -y
if [ $? -eq 0 ]; then
   echo SUCCESS
else
  echo FAILURE
fi

echo MySQL Install
yum install mysql-community-server -y
if [ $? -eq 0 ]; then
   echo SUCCESS
else
  echo FAILURE
fi

echo Enable MySQL Service
systemctl enable mysqld
if [ $? -eq 0 ]; then
   echo SUCCESS
else
  echo FAILURE
  fi

echo MySQL Start MySQL Service
systemctl restart mysqld
if [ $? -eq 0 ]; then
   echo SUCCESS
else
  echo FAILURE
fi

echo show databases | mysql -uroot -pRoboShop@1
if [ $? -ne 0 ];
then

 echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" > /tmp/root-pass-sql
 DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
 cat /tmp/root-pass-sql | mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}"

fi