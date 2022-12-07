if [ -z "$1" ]; then
  echo Input argument Password is needed
  exit
fi

COMPONENT=mysql
source common.sh
ROBOSHOP_MYSQL_PASSWORD=$1

PRINT "Downloading MySQL Repo File"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>$LOG
STAT $?

PRINT "Disable MYSQL 8 Version Repo"
dnf module disable mysql -y &>>$LOG
STAT $?

PRINT "Install MYSQL"
yum install mysql-community-server -y &>>$LOG
STAT $?

PRINT "Enable MYSQL Service"
systemctl enable mysqld &>>$LOG
STAT $?

PRINT "Start MYSQL Service"
systemctl restart mysqld &>>$LOG
STAT $?

echo show databases | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG
if [ $? -ne 0 ]
then
 echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROBOSHOP_MYSQL_PASSWORD}';" > /tmp/root-pass-sql
 DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
 cat /tmp/root-pass-sql | mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" &>>$LOG
fi

echo "show plugins" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} | grep validate_password &>>$LOG
if [ $? -eq 0 ]; then
  echo "unistall plugin validate_password;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG
 fi
 STAT $?