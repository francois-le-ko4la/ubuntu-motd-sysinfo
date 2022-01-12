# ubuntu-motd-sysinfo

```
git clone https://github.com/francois-le-ko4la/ubuntu-motd-sysinfo.git
cd ubuntu-motd-sysinfo/
sudo apt install figlet toilet toilet-fonts lolcat
sudo pip3 install -r requirements.txt
sudo cp 00-fprint-hostname 40-ubuntu-motd-sysinfo /etc/update-motd.d/
cd /etc/update-motd.d/
sudo chmod +x 00-fprint-hostname 40-ubuntu-motd-sysinfo
sudo chmod -x 50-landscape-sysinfo
```
