if [ -z "$1" ]; then
  echo Input argument Password Is Needed
  exit
fi

ROBOSHOP_MYSQL_PASSWORD=$1

STAT() {
if [ $1 -eq 0 ]; then
  echo SUCCESS
else
  echo FAILURE
  exit
 fi
}

PRINT "MySQL Repo Downloading"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
STAT $?

PRINT "Disable MySQL 8 Version Repo"
dnf module disable mysql -y
STAT $?

PRINT "MySQL Install"
yum install mysql-community-server -y
STAT $?

PRINT "Enable MySQL Service"
systemctl enable mysqld
STAT $?

PRINT "MySQL reStart MySQL Service"
systemctl restart mysqld
STAT $?

