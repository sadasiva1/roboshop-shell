STAT() {
 if [ $1 -eq 0 ]; then
   echo -e "\e[32mSUCCESS\e[0m"
 else
  echo -e "\e[31mFAILURE\e[0m"
  echo check the error in $LOG file
  exit
 fi
}

PRINT() {
  echo "-------------- $1 -------------" >>${LOG}
  echo -e "\e[33m$1\e[0m"
 }

LOG=/tmp/$COMPONENT.log
rm -f $LOG

NODEJS() {
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
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG
  STAT $?

  PRINT "Remove Previous Version App"
  cd /home/roboshop &>>$LOG
  rm -rf ${COMPONENT} &>>$LOG
  STAT $?

  PRINT "Extracting App Content"
  unzip -o /tmp/${COMPONENT}.zip &>>$LOG
  STAT $?

  mv ${COMPONENT}-main ${COMPONENT}
  cd ${COMPONENT}

  PRINT "Install NodeJs Dependencies App"
  npm install &>>$LOG
  STAT $?

  PRINT "Configure Endpoints For SystemD Configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis.sadasiva.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.sadasiva.online/' /home/roboshop/${COMPONENT}/systemd.service &>>$LOG
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  STAT $?

  PRINT "Reload SystemD"
  systemctl daemon-reload &>>$LOG
  STAT $?

  PRINT "Restart ${COMPONENT}"
  systemctl restart ${COMPONET} &>>$LOG
  STAT $?

  PRINT "Enable ${COMPONENT} Service"
  systemctl enable ${COMPONET} &>>$LOG
  STAT $?
}