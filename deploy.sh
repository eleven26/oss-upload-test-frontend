#!/bin/bash

npm run build

rm -rf dist/js/*.map

tar -zcf dist.tar.gz dist

scp dist.tar.gz root@106.75.182.171:/www/wwwroot

ssh root@106.75.182.171 << sshoff
    cd /www/wwwroot
    tar -xvf dist.tar.gz
    rm -rf oss-frontend.baiguiren.com
    mv dist oss-frontend.baiguiren.com
exit
sshoff

rm -rf dist.tar.gz

echo "done!"
