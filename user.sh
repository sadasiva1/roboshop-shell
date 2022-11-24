curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop


curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip"
cd /home/roboshop
rm -rf user
unzip -o /tmp/user.zip
mv user-main user
cd /home/roboshop/user
npm install

sed -i -e 's/REDIS_ENDPOINT/redis.sadasiva.online/' -e 's/MONGO_ENDPOINT/mongo.sadasiva.online/'
curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip"
cd /home/roboshop
unzip /tmp/user.zip
mv user-main user
cd /home/roboshop/user
npm install
