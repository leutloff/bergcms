
This is the default directory for mocha - a javascript test runner.



Install prerquisites

sudo apt-get install chromium-chromedriver unity-chromium-extension chromium-codecs-ffmpeg-extra

Download chromedriver from http://chromedriver.storage.googleapis.com/index.html?path=2.8/
extract chromedriver from downloaded ZIP file and copied it to /home/leutloff/bin which is part of PATH

sudo apt-get --purge remove google-chrome-stable
sudo apt-get install nodejs npm 
sudo apt-get install nodejs-legacy (add link: ln -s /usr/bin/nodejs /usr/bin/node)
sudo npm install wd
sudo npm install selenium-webdriver
sudo npm install -g mocha

then test the above installation of selenium-webdriver and call
mocha -R list --recursive node_modules/selenium-webdriver/test
