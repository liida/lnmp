#!/bin/bash
#date=2013-04-01
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=C
set -x 
#####################  set env #####################################
soft_dir=/data/soft
HOST_IP1="`/sbin/ifconfig em1 | grep 'inet addr' | awk '{print $2}' | sed -e 's/.*://'`"
Install_log=/data/Install_log

sed '8 aset encoding=prc' -i /etc/vimrc
sed '8 aset fileformats=unix' -i /etc/vimrc
sed '8 aset termencoding=utf-8' -i /etc/vimrc
sed '8 aset fileencodings=utf-8,gb2312,gbk,gb18030' -i /etc/vimrc

sed '8 aset encoding=prc' -i /etc/virc
sed '8 aset fileformats=unix' -i /etc/virc
sed '8 aset termencoding=utf-8' -i /etc/virc
sed '8 aset fileencodings=utf-8,gb2312,gbk,gb18030' -i /etc/virc

#############    Disable SeLinux  #################################
if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

############ download w1 base software  #####################
cd /data
unzip -q soft.zip
cd $soft_dir

###########  install w1 base software #######################
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype  libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2  ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel openldap-client openldap-servers gettext gettext-devel libmcrypt libmcrypt-devel libxml2-python
echo "############################ w1 php + mysql +nginx conf ##################################" > $Install_log
echo $? >> $Install_log
echo "NO.1 +++++++++++++++++   yum install software ok +++++++++++++" >> $Install_log
cd  $soft_dir
tar zxvf $soft_dir/libiconv-*.tar.gz
cd libiconv-*/
./configure --prefix=/usr/local/services
make
make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.2 +++++++++++++++++   libiconv install ok  ++++++++++++++++" >>$Install_log

tar zxvf libmcrypt-*.tar.gz 
cd libmcrypt-*/
./configure
make
make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make
make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.3 +++++++++++++++++++++  libmcrypt install ok +++++++++++++"  >>$Install_log

tar zxvf mhash-*.tar.gz
cd mhash-*/
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.4 +++++++++++++++++    mhash install ok  +++++++++++++++++++" >>$Install_log

tar zxvf libevent-*.tar.gz
cd libevent-*
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.5 +++++++++++++++++  libevent install ok ++++++++++++++++++++++++++" >>$Install_log

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1 
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config

cd $soft_dir
tar zxvf  mcrypt-*.tar.gz
sleep 60
cd mcrypt-*
/sbin/ldconfig
./configure
make 
make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.6 +++++++++++++++++  mcrypt install ok ++++++++++++++++++++++++++" >>$Install_log

#############################  mysql software install ###############################

tar zxvf cmake-*.tar.gz
cd cmake-*
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.6  +++++++++++++++++  cmake install ok ++++++++++++++++++++++++++" >>$Install_log

#######################  mysql tar Source install ###############################
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql
mkdir -p /data/mysql/data
mkdir -p /usr/local/services/mysql
tar zxvf mysql-5.5.*.tar.gz
cd mysql-5.5.*
cmake . \
-DCMAKE_BUILD_TYPE:STRING=Release \
-DCMAKE_INSTALL_PREFIX:PATH=/usr/local/services/mysql/ \
-DCOMMUNITY_BUILD:BOOL=ON \
-DENABLED_PROFILING:BOOL=ON \
-DENABLE_DEBUG_SYNC:BOOL=OFF \
-DINSTALL_LAYOUT:STRING=STANDALONE \
-DMYSQL_DATADIR:PATH=/data/mysql/data \
-DMYSQL_MAINTAINER_MODE:BOOL=OFF \
-DWITH_EMBEDDED_SERVER:BOOL=ON \
-DWITH_EXTRA_CHARSETS:STRING=all \
-DWITH_SSL:STRING=bundled \
-DWITH_UNIT_TESTS:BOOL=OFF \
-DWITH_ZLIB:STRING=bundled \
-LH
make && make install
echo $? >>$Install_log
ln -s /usr/local/services/mysql/lib/lib* /usr/lib/
/usr/local/services/mysql/scripts/mysql_install_db --basedir=/usr/local/services/mysql --datadir=/data/mysql/data --user=mysql
\cp -f $soft_dir/my.cnf-w1 /etc/my.cnf
\cp -f $soft_dir/mysql-5.5.*/support-files/mysql.server /usr/local/services/mysql/mysql
chmod +x /usr/local/services/mysql/mysql
chown -R mysql:mysql /data/mysql/
chmod +w /usr/local/services/mysql
chown -R mysql:mysql /usr/local/services/mysql
\cp -rf /usr/local/services/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start
cd $soft_dir
#####################     mysql binary install  ##########################
#/usr/sbin/groupadd mysql
#/usr/sbin/useradd -g mysql mysql
#if [ ! -d /data/ ]
#then
#mkdir -p /data/
#fi
#if [ -d /usr/local/services/mysql ]
#then
#mv /usr/local/services/mysql /usr/local/services/mysql_bak
#fi
#tar zxvf mysql-5.5.14-linux2.6-x86_64.tar.gz 
#\cp -rf mysql-5.5.14-linux2.6-x86_64 /usr/local/services/mysql
#chown -R mysql.mysql /usr/local/services/mysql
#chown -R mysql:mysql /data/
#rm -rf /usr/local/services/mysql/data
#ln -s /usr/local/services/mysql/lib/lib* /usr/lib/
#ln -s /data /usr/local/services/mysql/data
#cd /usr/local/services/mysql
#./scripts/mysql_install_db --user=mysql 
#\cp -rf $soft_dir/my.cnf-w1 /etc/my.cnf
#\cp -rf /usr/local/services/mysql/support-files/mysql.server /etc/init.d/mysqld
#chmod 755 /etc/init.d/mysqld
#/etc/init.d/mysqld start
#echo $? >>$Install_log
#cd $soft_dir
#echo "NO.7 +++++++++++++++++  mysql install ok ++++++++++++++++++++++++++" >>$Install_log

############################ php software install ###################################

mkdir -p /usr/local/services/freetype
mkdir -p /usr/local/services/gd
tar zxvf freetype-*.tar.gz
cd freetype-*
./configure --prefix=/usr/local/services/freetype
make
make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.8 +++++++++++++++++  freetype install  ok ++++++++++++++++++++++++++" >>$Install_log

tar jxvf gd-*.tar.bz2
cd gd-*
./configure --prefix=/usr/local/services/gd \
--with-jpeg \
--with-png \
--with-zlib \
--with-freetype=/usr/local/services/freetype
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.9 +++++++++++++++++  GD install  ok ++++++++++++++++++++++++++">>$Install_log

tar jxvf php-5.5.*.*
cd php-5.5.*
./configure --prefix=/usr/local/services/php \
--with-config-file-path=/usr/local/services/php/etc \
--with-mysql=/usr/local/services/mysql \
--with-pdo-mysql=/usr/local/services/mysql \
--with-mysqli=mysqlnd \
--with-iconv-dir=/usr/local/ \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-safe-mode \
--enable-shmop  \
--enable-sysvsem  \
--enable-inline-optimization  \
--with-curl \
--with-curlwrappers  \
--enable-mbregex  \
--enable-fpm  \
--enable-mbstring  \
--enable-pcntl  \
--enable-sockets   \
--with-xmlrpc  \
--enable-zip   \
--without-pear  \
--with-openssl \
--with-mhash   \
--disable-phar \
--with-gd=/usr/local/services/gd \
--with-freetype-dir=/usr/local/services/freetype \
--enable-bcmath \
--with-mcrypt  \
--enable-soap \
--enable-opcache

sed '27 avoid (*data);' -i /usr/local/services/gd/include/gd_io.h
make
make install
echo $? >>$Install_log
\cp $soft_dir/php.ini-w1 /usr/local/services/php/etc/php.ini
\cp -f /usr/local/services/lib/libiconv.so.2 /usr/lib/libiconv.so.2 
\cp -f /usr/local/services/lib/libiconv.so.2 /usr/lib64/libiconv.so.2 
\cp $soft_dir/go-pear.phar /usr/local/services/php/bin/php
ln -s /usr/local/services/lib/libionv.so.2 /usr/lib/libiconv.so.2
ln -s /usr/local/services/mysql/lib/libmysqlclient.so.18 /usr/lib
cd $soft_dir 
echo "NO.10  +++++++++++++++++  php install  ok ++++++++++++++++++++++++++">>$Install_log

tar zxvf graphviz-*.tar.gz
cd graphviz-*
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.11 +++++++++++++++++  graphviz install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf memcache-*.tgz
cd memcache-*/
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.12 +++++++++++++++++  memcache install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf PDO_MYSQL-*.tgz
cd PDO_MYSQL-*/
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config \
--with-pdo-mysql=/usr/local/services/mysql
ln -s /usr/local/services/mysql/include/* /usr/include/ 
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.13 +++++++++++++++++  PDO_MYSQL install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf game.tar.gz
cd game
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.14 +++++++++++++++++  memcache install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf ImageMagick-6.7.7-0.tar.gz
cd ImageMagick-*/
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.14 +++++++++++++++++  ImageMagic install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf imagick-*.tgz
cd imagick-*/
/usr/local/services/php/bin/phpize
export PKG_CONFIG_LIBDIR=/usr/local/lib/pkgconfig
./configure --with-php-config=/usr/local/services/php/bin/php-config --with-imagick=/usr/local/lib/ImageMagick-6.7.7
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.15 +++++++++++++++++  imagic install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf APC-*.tgz 
cd APC-*
/usr/local/services/php/bin/phpize
./configure --enable-apc \
--enable-apc-mmap \
--with-php-config=/usr/local/services/php/bin/php-config
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.16 +++++++++++++++++  APC install  ok ++++++++++++++++++++++++++" >>$Install_log

tar xvf neoxic-php-amf3-f6273ff.tar.gz  
cd neoxic-php-amf3-f6273ff
/usr/local/services/php/bin/phpize
./configure --enable-amf3 \
--with-php-config=/usr/local/services/php/bin/php-config
make install
echo $? >>$Install_log 
cd $soft_dir
echo "NO.17 +++++++++++++++++  amf3 install  ok ++++++++++++++++++++++++++" >>$Install_log

unzip igbinary-master.zip
cd  igbinary-master/
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config \
--enable-igbinary
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.18 +++++++++++++++++  phadej-igbinary install  ok ++++++++++++++++++++++++++" >>$Install_log

tar xvf nicolasff-phpredis-2.2.2-52-g70430fb.tar.gz
cd nicolasff-phpredis-70430fb/
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config --enable-redis-igbinary
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.19 +++++++++++++++++  PHPredis install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf tcl8.*.tar.gz 
cd tcl8.*/unix/
./configure
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.20 +++++++++++++++++  tcl install  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf redis-*.tar.gz
cd redis-*
make && make install
echo $? >>$Install_log
mkdir -p /usr/local/services/redis/bin
mkdir -p /usr/local/services/redis/etc
mkdir -p /usr/local/services/redis/var
cd src/
\cp -rf redis-benchmark redis-check-aof redis-cli redis-server redis-check-dump  /usr/local/services/redis/bin/
\cp -rf $soft_dir/redis.conf-w1  /usr/local/services/redis/etc/redis.conf
/usr/local/services/redis/bin/redis-server /usr/local/services/redis/etc/redis.conf &
cd $soft_dir
echo "NO.21 +++++++++++++++++  redis install  ok ++++++++++++++++++++++++++" >>$Install_log

/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
mkdir -p /data/htdocs
chmod +w /data/htdocs/
chown -R www:www /data/htdocs/
\cp -rf $soft_dir/php-fpm.conf-w1 /usr/local/services/php/etc/php-fpm.conf
ln -s /usr/local/services/lib/libionv.so.2 /usr/lib/libiconv.so.2
ulimit -SHn 65535
\cp -rf $soft_dir/php-5.4.*/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm
chmod u+x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
export LD_LIBRARY_PATH="/usr/local/services/mysql/lib:$LD_LIBRARY_PATH"
sed -i "s/allow_call_time_pass_reference/;allow_call_time_pass_reference/g" /usr/local/services/php/etc/php.ini
/etc/init.d/php-fpm start
echo $? >>$Install_log
cd $soft_dir
echo "NO.23 +++++++++++++++++  php start  ok ++++++++++++++++++++++++++" >>$Install_log

tar zxvf pcre-*.tar.gz 
cd pcre-*
./configure 
make && make install
echo $? >>$Install_log
cd $soft_dir
echo "NO.24 +++++++++++++++++  pcre install  ok ++++++++++++++++++++++++++" >>$Install_log

mkdir -p /data/www/logs/cron
tar zxvf ngx_cache_purge-*.tar.gz
tar zxvf  nginx-1.*.tar.gz 
cd nginx-1.*/
./configure --user=www \
--group=www \
--add-module=../ngx_cache_purge-1.6 \
--prefix=/usr/local/services/nginx \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-pcre=/data/soft/pcre-8.31
make && make install
echo $? >>$Install_log
cd $soft_dir
\cp -rf $soft_dir/nginx-w1 /etc/init.d/nginx
chmod u+x /etc/init.d/nginx
mv /usr/local/services/nginx/conf/nginx.conf /usr/local/services/nginx/conf/nginx.conf.orig
\cp -rf $soft_dir/nginx.conf-w1 /usr/local/services/nginx/conf/nginx.conf
\cp -rf $soft_dir/fcgi.conf-w1 /usr/local/services/nginx/conf/fcgi.conf
mkdir -p /usr/local/services/nginx/conf/vhosts/
\cp -rf $soft_dir/web.conf-w1 /usr/local/services/nginx/conf/vhosts/web.conf
\cp -rf $soft_dir/skydunk.conf-w1 /usr/local/services/nginx/conf/vhosts/skydunk.conf
ulimit -SHn 65535
mkdir -p /data/logs
ln -s /usr/local/lib/libpcre.so.1 /usr/lib64/libpcre.so.1
/etc/init.d/nginx start
cd $soft_dir
echo "NO.25 +++++++++++++++++  NGINX install  ok ++++++++++++++++++++++++++"  >>$Install_log

mkdir -p /usr/local/www/wwwroot/
tar zxvf xhprof-*.tgz
cd xhprof-*
\cp -a xhprof_html xhprof_lib /usr/local/www/wwwroot/
cd extension/
/usr/local/services/php/bin/phpize
./configure --with-php-config=/usr/local/services/php/bin/php-config
make && make install
echo $? >>$Install_log
cd $soft_dir

echo "NO.26 +++++++++++++++++  xhprof install  ok ++++++++++++++++++++++++++" >>$Install_log
chown -R www.www /data/htdocs
\cp -rf $soft_dir/phptest.php /data/htdocs

sed -i "s/127001/$HOST_IP1/" /usr/local/services/nginx/conf/vhosts/web.conf
/etc/init.d/php-fpm restart
/etc/init.d/nginx restart

cd $soft_dir/php-5.4.*
make install
ln -s /usr/local/services/php/bin/php /usr/bin/php

echo "++++++++++++  please web verify php module http://ip/phptest.php  ++++++++++++++"
echo '*                    soft     core            unlimited' >> /etc/security/limits.conf
echo '*                    hard     core            unlimited' >> /etc/security/limits.conf
echo "php module nubmer "&& /usr/local/services/php/bin/php -m |wc -l
echo `/usr/local/services/php/bin/php -m` >> $Install_log
echo '/etc/init.d/mysqld start' >> /etc/rc.local
echo '/etc/init.d/nginx restart' >> /etc/rc.local
echo '/etc/init.d/php-fpm restart' >> /etc/rc.local
echo '/usr/local/services/redis/bin/redis-server /usr/local/services/redis/etc/redis.conf &' >> /etc/rc.local

