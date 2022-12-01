COMPONENT=cart
source common.sh

PRINT "Install NodeJs Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG
STAT $?

PRINT "Install NodeJs"
yum install nodejs -y &>>$LOG
STAT $?

PRINT "Adding Apllication User"
id roboshop &>>$LOG
if [ $? -ne 0 ]; then
 useradd roboshop &>>$LOG
fi
STAT $?

PRINT "Download App Content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>$LOG
STAT $?

PRINT "Remove Previous Version App"
cd /home/roboshop &>>$LOG
rm -rf cart &>>$LOG
STAT $?

PRINT "Extracting App Content"
unzip -o /tmp/cart.zip &>>$LOG
STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJs Dependencies App"
npm install &>>$LOG
STAT $?

PRINT "Configure Endpoints For SystemD Configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.sadasiva.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.sadasiva.online/' /home/roboshop/cart/systemd.service &>>$LOG
STAT $?

PRINT "Reload SystemD"
systemctl daemon-reload &>>$LOG
STAT $?

PRINT "Restart Cart"
systemctl restart cart &>>$LOG
STAT $?

PRINT "Enable Cart Service"
systemctl enable cart &>>$LOG
STAT $?

echo show databases | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD}
if [ $? -ne 0 ];
then

 echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROBOSHOP_MYSQL_PASSWORD';" > /tmp/root-pass-sql
 DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
 cat /tmp/root-pass-sql | mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}"

fi

