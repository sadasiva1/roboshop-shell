STAT() {
 if [ $1 -eq 0 ]; then
   echo -e "\e[32mSUCCESS\e[0m"
 else
  echo -e "\e[31mFAILURE\e[0m"
  echo check the error $LOG file
  exit
 fi
}

PRINT() {
  echo "-------------- $1 -------------" >>${LOG}
  echo -e "\e[33m$1\e[0m"
}

LOG=/tmp/$COMPONENT.log
rm -f $LOG
set-hostname -skip-apply $COMPONENT

DOWNLOAD_APP_CODE() {
  if [ ! -z "$APP_USER" ]; then
   PRINT "Adding Apllication User"
   id roboshop &>>LOG
   if [ $? -ne 0 ]; then
     useradd roboshop &>>$LOG
   fi
   STAT $?
  fi

  PRINT "Download App Content"
  curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/roboshop-devops-project/$COMPONENT/archive/main.zip" &>>$LOG
  STAT $?

  PRINT "Removing Previous Version Of App"
  cd $APP_LOC &>>$LOG
  rm -rf $CONTENT &>>$LOG
  STAT $?

  PRINT "Extracting App Content"
  unzip -o /tmp/${COMPONENT}.zip &>>$LOG
  STAT $?
}

  SYSTEMD_SETUP() {
  PRINT "Configure Endpoints For SystemD Configuration"
  sed -i -e 's/MONGO_DNSNAME/dev-mongodb.sadasiva.online/' -e 's/REDIS_ENDPOINT/dev-redis.sadasiva.online/' -e 's/CATALOGUE_ENDPOINT/dev-catalogue.sadasiva.online/' -e 's/MONGO_ENDPOINT/dev-mongodb.sadasiva.online/' -e 's/CARTENDPOINT/dev-cart.sadasiva.online/' -e 's/DBHOST/dev-mysql.sadasiva.online/' -e 's/AMQPHOST/dev-rabbitmq.sadasiva.online/' -e 's/CARTHOST/dev-cart.sadasiva.online/' -e 's/USERHOST/dev-user.sadasiva.online/' /home/roboshop/${COMPONENT}/systemd.service &>>$LOG
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  STAT $?

  PRINT "Reload SystemD"
  systemctl daemon-reload &>>$LOG
  STAT $?

  PRINT "Restart ${COMPONENT}"
  systemctl restart ${COMPONENT} &>>$LOG
  STAT $?

  PRINT "Enable ${COMPONENT} Service"
  systemctl enable ${COMPONENT} &>>$LOG
  STAT $?
}

NODEJS() {
  APP_LOC=/home/roboshop
  CONTENT=$COMPONENT
  APP_USER=roboshop
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

  DOWNLOAD_APP_CODE

  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install NodeJs Dependencies For App"
  npm install &>>$LOG
  STAT $?

 SYSTEMD_SETUP
 }

JAVA() {
  APP_LOC=/home/roboshop
  CONTENT=$COMPONENT
  APP_USER=roboshop

  PRINT "Install Maven"
  yum install maven -y &>>$LOG
  STAT $?

  DOWNLOAD_APP_CODE

   mv ${COMPONENT}-main ${COMPONENT}
   cd ${COMPONENT}

  PRINT "Download Maven Dependencies"
  mvn clean package &>>$LOG && mv target/$COMPONENT-1.0.jar shipping.jar &>>$LOG
  STAT $?

  SYSTEMD_SETUP
}

PHYTON() {
    APP_LOC=/home/roboshop
    CONTENT=$COMPONENT
    APP_USER=roboshop

    PRINT "Install Python"
    yum install python36 gcc python3-devel -y &>>$LOG
    STAT $?

    DOWNLOAD_APP_CODE
    mv ${COMPONENT}-main ${COMPONENT}
    cd ${COMPONENT}

    PRINT "Install Python Dependencies"
    pip3 install -r requirements.txt  &>>$LOG
    STAT $?


    USER_ID=$(id -u roboshop)
    GROUP_ID=$(id -g roboshop)
    sed -i -e "/uid/ c uid = ${USER_ID}" -e "/uid/ c uid = ${GROUP_ID}" ${COMPONENT}.ini

    SYSTEMD_SETUP

    }

