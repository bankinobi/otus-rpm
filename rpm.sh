#!/bin/bash

yum install -y \
  redhat-lsb-core \
  wget \
  rpmdevtools \
  rpm-build \
  createrepo \
  yum-utils \
  epel-release \
  gcc \
  gcc-c++

cd /root

curl -sL \
https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm \
-o nginx-1.14.1-1.el7_4.ngx.src.rpm

wget -qO- https://www.openssl.org/source/latest.tar.gz | tar -xvzf -

rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm

yum-builddep -y rpmbuild/SPECS/nginx.spec

sed -i 's+--with-debug+--with-openssl=/root/openssl-1.1.1k+g' \
rpmbuild/SPECS/nginx.spec

rpmbuild -bb rpmbuild/SPECS/nginx.spec

yum localinstall -y \
rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm

mkdir /usr/share/nginx/html/repo

cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/

curl -sL \
https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
-o /usr/share/nginx/html/repo/remi-release-7.rpm

createrepo /usr/share/nginx/html/repo/

sed -i '/index  index.html index.htm;/a \\tautoindex on;' \
/etc/nginx/conf.d/default.conf

systemctl restart nginx

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

yum install -y remi-release

yum list installed | grep remi
