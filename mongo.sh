COMPONENT=mongodb
source common.sh

PRINT "Download YUM Repo File"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG
STAT $?

PRINT "Install MongoDB"
yum install -y mongodb-org &>>$LOG
STAT $?

PRINT "Configure MongoDB Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOG
STAT $?

PRINT "Enable MongoDB"
systemctl enable mongod &>>$LOG
STAT $?

PRINT "Start MongoDB"
systemctl restart mongod &>>$LOG
STAT $?

exit
PRINT ""
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG
STAT $?
cd /tmp

PRINT""
unzip -o mongodb.zip &>>$LOG
STAT $?

cd mongodb-main &>>$LOG

PRINT""
mongo < catalogue.js &>>$LOG
STAT $?

PRINT""
mongo < users.js &>>$LOG
STAT $?
