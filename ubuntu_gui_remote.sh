#!/bin/sh

sudo apt-get update -y
sudo apt-get upgrade -y

adduser wolf
addgroup wolf sudo

ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 5901

sudo apt-get install -y xfce4 xfce4-goodies tightvncserver firefox expect git
sudo su - wolf
sudo vncserver

sudo vncserver -kill :1
sudo cp ~/.vnc/xstartup ~/.vnc/xstartup.bak

sudo echo "startxfce4 &" >> ~/.vnc/xstartup

sudo cat > /etc/systemd/system/vncserver@.service << EOF
[Unit]
 Description=Remote desktop service (VNC)
 After=syslog.target network.target

[Service]
  Type=forking
  User=wolf
  PIDFile=/home/wolf/.vnc/%H:%i.pid
  ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
  ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
  ExecStop=/usr/bin/vncserver -kill :%i

[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now vncserver@1.service

sudo reboot
