source common.sh

PRINT "Install NodeJs Repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
STAT $?

PRINT "Install NodeJs"
yum install nodejs -y
STAT $?

PRINT "Adding Apllication User"
useradd roboshop
STAT $?

PRINT "Download App Content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip"
STAT $?

PRINT "Remove Previous Version App"
cd /home/roboshop
rm -rf cart
STAT $?

PRINT "Extracting App Content"
unzip -o /tmp/cart.zip
STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJs Dependencies App"
npm install
STAT $?

PRINT "Configure Endpoints For SystemD Configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.sadasiva.online/' -e 's/CATALOGUE_ENDPOINT/catalogue.sadasiva.online/'
STAT $?

PRINT "Setup SystemD Service"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service
STAT $?

PRINT "Reload SystemD"
systemctl daemon-reload
STAT $?

PRINT "Restart Cart"
systemctl restart cart
STAT $?

PRINT "Enable Cart Service"
systemctl enable cart
STAT $?

