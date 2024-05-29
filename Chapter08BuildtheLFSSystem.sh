#!/bin/bash

#This is done in ___ Environment.

#Change Directory into $LFS/sources
cd $LFS/sources

#Man-pages-6.06
tar -xvf man-pages-6.06.tar.xz
cd man-pages-6.06

rm -v man3/crypt*

make prefix=/usr install

cd $LFS/sources
rm -Rf man-pages-6.06

#Iana-Etc-20240125
tar -xvf iana-etc-20240125.tar.gz
cd iana-etc-20240125

cp services protocols /etc

cd $LFS/sources
rm -Rf iana-etc-20240125

#Glibc-2.39
tar -xvf glibc-2.39.tar.xz
cd glibc-2.39

patch -Np1 -i ../glibc-2.39-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=4.19                     \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib

make

make check

touch /etc/ld.so.conf

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

mkdir -pv /usr/lib/locale
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2024a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

tzselect

ln -sfv /usr/share/zoneinfo/<xxx> /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

cd $LFS/sources
rm -Rf glibc-2.39

#Zlib-1.3.1
tar -xvf zlib-1.3.1.tar.gz
cd zlib-1.3.1

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libz.a

cd $LFS/sources
rm -Rf zlib-1.3.1

#Bzip2-1.0.8
tar -xvf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean

make

make PREFIX=/usr install

cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

rm -fv /usr/lib/libbz2.a

cd $LFS/sources
rm -Rf bzip2-1.0.8

#Xz-5.4.6
tar -xvf xz-5.4.6.tar.xz
cd xz-5.4.6

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.6

make

make check

make install

cd $LFS/sources
rm -Rf xz-5.4.6

#Zstd-1.5.5
tar -xvf zstd-1.5.5.tar.gz
cd zstd-1.5.5

make prefix=/usr

make check

make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd $LFS/sources
rm -Rf zstd-1.5.5

#File-5.45
tar -xvf file-5.45.tar.gz
cd file-5.45

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf file-5.45

#Readline-8.2
tar -xvf readline-8.2.tar.gz
cd readline-8.2

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

patch -Np1 -i ../readline-8.2-upstream_fixes-3.patch

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2

make SHLIB_LIBS="-lncursesw"

make SHLIB_LIBS="-lncursesw" install

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2

cd $LFS/sources
rm -Rf readline-8.2

#M4-1.4.19
tar -xvf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf m4-1.4.19

#Bc-6.7.5
tar -xvf bc-6.7.5.tar.xz
cd bc-6.7.5

CC=gcc ./configure --prefix=/usr -G -O3 -r

make

make test

make install

cd $LFS/sources
rm -Rf bc-6.7.5

#Flex-2.6.4
tar -xvf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

make check

make install

ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd $LFS/sources
rm -Rf flex-2.6.4

#Tcl-8.6.13
tar -xvf tcl8.6.13-src.tar.gz
cd tcl8.6.13

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man

make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
    -i pkgs/tdbc1.1.5/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
    -i pkgs/itcl4.2.3/itclConfig.sh

unset SRCDIR

make test

make install

chmod -v u+w /usr/lib/libtcl8.6.so

make install-private-headers

ln -sfv tclsh8.6 /usr/bin/tclsh

mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

cd ..
tar -xf ../tcl8.6.13-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.13
cp -v -r  ./html/* /usr/share/doc/tcl-8.6.13

cd $LFS/sources
rm -Rf tcl8.6.13-src

#Expect-5.45.4
tar -xvf expect5.45.4.tar.gz
cd expect5.45.4

python3 -c 'from pty import spawn; spawn(["echo", "ok"])'

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make

make test

make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd $LFS/sources
rm -Rf expect5.45.4

#DejaGNU-1.6.3
tar -xvf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

make check

make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cd $LFS/sources
rm -Rf dejagnu-1.6.3

#Pkgconf-2.1.1.
tar -xvf pkgconf-2.1.1.tar.xz
cd pkgconf-2.1.1

./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.1.1

make

make install

ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd $LFS/sources
rm -Rf pkgconf-2.1.1

#Binutils-2.42
tar -xvf binutils-2.42.tar.xz
cd binutils-2.42

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make tooldir=/usr

make -k check

grep '^FAIL:' $(find -name '*.log')

make tooldir=/usr install

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

cd $LFS/sources
rm -Rf binutils-2.42

#GMP-6.3.0
tar -xvf gmp-6.3.0.tar.xz
cd gmp-6.3.0

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

cd $LFS/sources
rm -Rf gmp-6.3.0

#MPFR-4.2.1
tar -xvf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1

make
make html

make check

make install
make install-html

cd $LFS/sources
rm -Rf mpfr-4.2.1

#MPC-1.3.1
tar -xvf mpc-1.3.1.tar.gz
cd mpc-1.3.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

make
make html

make check

make install
make install-html

cd $LFS/sources
rm -Rf mpfr-4.2.1

#Attr-2.5.2
tar -xvf attr-2.5.2.tar.gz
cd attr-2.5.2

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

make

make check

make install

cd $LFS/sources
rm -Rf attr-2.5.2

#Acl-2.3.2
tar -xvf acl-2.3.2.tar.xz
cd acl-2.3.2

./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2

make

make install

cd $LFS/sources
rm -Rf acl-2.3.2

#Libcap-2.69
tar -xvf libcap-2.69.tar.xz
cd libcap-2.69

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

make test

make prefix=/usr lib=lib install

cd $LFS/sources
rm -Rf acl-2.3.2

#Libxcrypt-4.4.36
tar -xvf libxcrypt-4.4.36.tar.xz
cd libxcrypt-4.4.36

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

make

make check

make install

cd $LFS/sources
rm -Rf libxcrypt-4.4.36

#Shadow-4.14.5
tar -xvf shadow-4.14.5.tar.xz
cd shadow-4.14.5

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32

make

make exec_prefix=/usr install
make -C man install-man

pwconv

grpconv

mkdir -p /etc/default
useradd -D --gid 999

sed -i '/MAIL/s/yes/no/' /etc/default/useradd

passwd root

cd $LFS/sources
rm -Rf shadow-4.14.5

#GCC-13.2.0
tar -xvf gcc-13.2.0.tar.xz
cd gcc-13.2.0

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

make

ulimit -s 32768

chown -R tester .
su tester -c "PATH=$PATH make -k check"

../contrib/test_summary

make install

chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/13.2.0/include{,-fixed}

ln -svr /usr/bin/cpp /usr/lib

ln -sv gcc.1 /usr/share/man/man1/cc.1

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd $LFS/sources
rm -Rf gcc-13.2.0

#Ncurses-6.4-20230520
tar -xvf ncurses-6.4-20230520
cd ncurses-6.4-20230520

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

make

make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.4
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /

for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so

cp -v -R doc -T /usr/share/doc/ncurses-6.4-20230520

cd $LFS/sources
rm -Rf ncurses-6.4-20230520

#Sed-4.9
tar -xvf sed-4.9.tar.xz
cd sed-4.9

./configure --prefix=/usr

make
make html

chown -R tester .
su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd $LFS/sources
rm -Rf sed-4.9

#Psmisc-23.6
tar -xvf psmisc-23.6.tar.xz
cd psmisc-23.6

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf psmisc-23.6

#Gettext-0.22.4
tar -xvf gettext-0.22.4.tar.xz
cd gettext-0.22.4

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd $LFS/sources
rm -Rf gettext-0.22.4

#Bison-3.8.2
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

make

make check

make install

cd $LFS/sources
rm -Rf bison-3.8.2

#Grep-3.11
tar -xvf grep-3.11.tar.xz
cd grep-3.11

sed -i "s/echo/#echo/" src/egrep.sh

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf grep-3.11

#Bash-5.2.21
tar -xvf bash-5.2.21.tar.gz
cd bash-5.2.21

patch -Np1 -i ../bash-5.2.21-upstream_fixes-1.patch

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.21

make

chown -R tester .

su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install

exec /usr/bin/bash --login

cd $LFS/sources
rm -Rf bash-5.2.21

#Libtool-2.4.7
tar -xvf libtool-2.4.7.tar.xz
cd libtool-2.4.7

./configure --prefix=/usr

make

make -k check

make install

rm -fv /usr/lib/libltdl.a

cd $LFS/sources
rm -Rf libtool-2.4.7

#GDBM-1.23
tar -xvf gdbm-1.23.tar.gz
cd gdbm-1.23

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

make check

make install

cd $LFS/sources
rm -Rf gdbm-1.23

#gperf-3.1
tar -xvf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make

make -j1 check

make install

cd $LFS/sources
rm -Rf gperf-3.1

#Expat-2.6.0
tar -xvf expat-2.6.0.tar.xz
cd expat-2.6.0

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.0

make

make check

make install

install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.0

cd $LFS/sources
rm -Rf expat-2.6.0

#Inetutils-2.5
tar -xvf inetutils-2.5.tar.xz
cd inetutils-2.5

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

make check

make install

mv -v /usr/{,s}bin/ifconfig

cd $LFS/sources
rm -Rf inetutils-2.5

#Less-643
tar -xvf less-643.tar.gz
cd less-643

./configure --prefix=/usr --sysconfdir=/etc

make

make check

make install

cd $LFS/sources
rm -Rf less-643

#Perl-5.38.2
tar -xvf perl-5.38.2.tar.xz
cd perl-5.38.2

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl      \
             -Darchlib=/usr/lib/perl5/5.38/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads

make

TEST_JOBS=$(nproc) make test_harness

make install
unset BUILD_ZLIB BUILD_BZIP2

cd $LFS/sources
rm -Rf perl-5.38.2

#XML::Parser-2.47
tar -xvf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

perl Makefile.PL

make

make test

make install

cd $LFS/sources
rm -Rf XML-Parser-2.47

#Intltool-0.51.0
tar -xvf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd $LFS/sources
rm -Rf intltool-0.51.0

#Autoconf-2.72
tar -xvf autoconf-2.72.tar.xz
cd autoconf-2.72

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf autoconf-2.72

#Automake-1.16.5
tar -xvf automake-1.16.5.tar.xz
cd automake-1.16.5

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5

make

make -j$(($(nproc)>4?$(nproc):4)) check

make install

cd $LFS/sources
rm -Rf automake-1.16.5

#OpenSSL-3.2.1
tar -xvf openssl-3.2.1.tar.gz
cd openssl-3.2.1

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

HARNESS_JOBS=$(nproc) make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.2.1

cp -vfr doc/* /usr/share/doc/openssl-3.2.1

cd $LFS/sources
rm -Rf openssl-3.2.1

#Kmod-31
tar -xvf kmod-31.tar.xz
cd kmod-31

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib

make

make install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done

ln -sfv kmod /usr/bin/lsmod

cd $LFS/sources
rm -Rf kmod-31

#Libelf from Elfutils-0.190
tar -xvf elfutils-0.190.tar.bz2
cd elfutils-0.190

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd $LFS/sources
rm -Rf elfutils-0.190

#Libffi-3.4.4
tar -xvf libffi-3.4.4.tar.gz
cd libffi-3.4.4

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make

make check

make install

cd $LFS/sources
rm -Rf libffi-3.4.4

#Python-3.12.2
tar -xvf Python-3.12.2.tar.xz
cd Python-3.12.2

./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations

make

make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.12.2/html

tar --no-same-owner \
    -xvf ../python-3.12.2-docs-html.tar.bz2
cp -R --no-preserve=mode python-3.12.2-docs-html/* \
    /usr/share/doc/python-3.12.2/html

cd $LFS/sources
rm -Rf Python-3.12.2

#Flit-Core-3.9.0
tar -xvf flit_core-3.9.0.tar.gz
cd flit_core-3.9.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist flit_core

cd $LFS/sources
rm -Rf flit_core.3.9.0

#Wheel-0.42.0
tar -xvf wheel-0.42.0.tar.gz
cd wheel-0.42.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links=dist wheel

cd $LFS/sources
rm -Rf wheel-0.42.0

#Setuptools-69.1.0
tar -xvf setuptools-69.1.0.tar.gz
cd setuptools-69.1.0

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist setuptools

cd $LFS/sources
rm -Rf setuptools-69.1.0

#Ninja-1.11.1
tar -xvf ninja-1.11.1.tar.gz
cd ninja-1.11.1

export NINJAJOBS=8

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd $LFS/sources
rm -Rf ninja-1.11.1

#Meson-1.3.2
tar -xvf meson-1.3.2.tar.gz
cd meson-1.3.2

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd $LFS/sources
rm -Rf meson-1.3.2

#Coreutils-9.4
tar -xvf coreutils-9.4.tar.xz
cd coreutils-9.4

patch -Np1 -i ../coreutils-9.4-i18n-1.patch

sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' \
    -i src/split.c

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

make NON_ROOT_USERNAME=tester check-root

groupadd -g 102 dummy -U tester

chown -R tester . 

su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

groupdel dummy

make install

mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd $LFS/sources
rm -Rf coreutils-9.4

#Check-0.15.2
tar -xvf check-0.15.2.tar.gz
cd check-0.15.2

./configure --prefix=/usr --disable-static

make

make check

make docdir=/usr/share/doc/check-0.15.2 install

cd $LFS/sources
rm -Rf check-0.15.2

#Diffutils-3.10
tar -xvf diffutils-3.10.tar.xz
cd diffutils-3.10

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf diffutils-3.10

#Gawk-5.3.0
tar -xvf gawk-5.3.0.tar.xz
cd gawk-5.3.0

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

chown -R tester .
su tester -c "PATH=$PATH make check"

rm -f /usr/bin/gawk-5.3.0
make install

ln -sv gawk.1 /usr/share/man/man1/awk.1

mkdir -pv                                   /usr/share/doc/gawk-5.3.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0

cd $LFS/sources
rm -Rf gawk-5.3.0

#Findutils-4.9.0
tar -xvf findutils-4.9.0.tar.xz
cd findutils-4.9.0

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install

cd $LFS/sources
rm -Rf findutils-4.9.0

#Groff-1.23.0
tar -xvf groff-1.23.0.tar.gz
cd groff-1.23.0

PAGE=<paper_size> ./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf groff-1.23.0

#GRUB-2.12
tar -xvf grub-2.12.tar.xz
cd grub-2.12

#check again for grub

#Gzip-1.13
tar -xvf gzip-1.13.tar.xz
cd gzip-1.13

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf gzip-1.13

#IPRoute2-6.7.0
tar -xvf iproute2-6.7.0.tar.xz
cd iproute2-6.7.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns

make SBINDIR=/usr/sbin install

mkdir -pv             /usr/share/doc/iproute2-6.7.0
cp -v COPYING README* /usr/share/doc/iproute2-6.7.0

cd $LFS/sources
rm -Rf iproute2-6.7.0

#Kbd-2.6.4
tar -xvf kbd-2.6.4.tar.xz
cd kbd-2.6.4

patch -Np1 -i ../kbd-2.6.4-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make

make check

make install

cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4

cd $LFS/sources
rm -Rf kbd-2.6.4

#Libpipeline-1.5.7
tar -xvf libpipeline-1.5.7.tar.gz
cd libpipeline-1.5.7

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf libpipeline-1.5.7

#Make-4.4.1
tar -xvf make-4.4.1.tar.gz
cd make-4.4.1

./configure --prefix=/usr

make

chown -R tester .
su tester -c "PATH=$PATH make check"

make install

cd $LFS/sources
rm -Rf make-4.4.1

#Patch-2.7.6
tar -xvf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr

make

make check

make install

cd $LFS/sources
rm -Rf patch-2.7.6

#Tar-1.35
tar -xvf tar-1.35.tar.xz
cd tar-1.35

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd $LFS/sources
rm -Rf tar-1.35

#Texinfo-7.1
tar -xvf texinfo-7.1.tar.xz
cd texinfo-7.1

./configure --prefix=/usr

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

cd $LFS/sources
rm -Rf texinfo-7.1

#Vim-9.1.0041
tar -xvf vim-9.1.0041.tar.gz
cd vim-9.1.0041

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -R tester .

su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
   &> vim-test.log

make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0041

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd $LFS/sources
rm -Rf vim-9.1.0041

#MarkupSafe-2.1.5
tar -xvf MarkupSafe-2.1.5.tar.gz
cd MarkupSafe-2.1.5

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist Markupsafe

cd $LFS/sources
rm -Rf MarkupSafe-2.1.5

#Jinja2-3.1.3
tar -xvf Jinja2-3.1.3.tar.gz
cd Jinja2-3.1.3

pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

pip3 install --no-index --no-user --find-links dist Jinja2

cd $LFS/sources
rm -Rf Jinja2-3.1.3

#Systemd-255
tar -xvf systemd-255.tar.gz
cd systemd-255

sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

patch -Np1 -i ../systemd-255-upstream_fixes-1.patch

mkdir -p build
cd       build

meson setup \
      --prefix=/usr                 \
      --buildtype=release           \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dldconfig=false              \
      -Dsysusers=false              \
      -Drpmmacrosdir=no             \
      -Dhomed=disabled              \
      -Duserdb=false                \
      -Dman=disabled                \
      -Dmode=release                \
      -Dpamconfdir=no               \
      -Ddev-kvm-mode=0660           \
      -Dnobody-group=nogroup        \
      -Dsysupdate=disabled          \
      -Dukify=disabled              \
      -Ddocdir=/usr/share/doc/systemd-255 \
      ..

ninja

ninja install

tar -xf ../../systemd-man-pages-255.tar.xz \
    --no-same-owner --strip-components=1   \
    -C /usr/share/man

systemd-machine-id-setup

systemctl preset-all

cd $LFS/sources
rm -Rf systemd-255

#D-Bus-1.14.10
tar -xvf dbus-1.14.10.tar.xz
cd dbus-1.14.10

./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --runstatedir=/run                   \
            --enable-user-session                \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.14.10 \
            --with-system-socket=/run/dbus/system_bus_socket

make

make check

make install

ln -sfv /etc/machine-id /var/lib/dbus

cd $LFS/sources
rm -Rf dbus-1.14.10

#Man-DB-2.12.0
tar -xvf man-db-2.12.0.tar.xz
cd man-db-2.12.0

./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.12.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap

make

make check

make install

cd $LFS/sources
rm -Rf man-db-2.12.0

#Procps-ng-4.0.4
tar -xvf procps-ng-4.0.4.tar.xz
cd procps-ng-4.0.4

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.4 \
            --disable-static                        \
            --disable-kill                          \
            --with-systemd

make src_w_LDADD='$(LDADD) -lsystemd'

make -k check

make install

cd $LFS/sources
rm -Rf procps-ng-4.0.4

#Util-linux-2.39.3
tar -xvf util-linux-2.39.3.tar.xz
cd util-linux-2.39.3

sed -i '/test_mkfds/s/^/#/' tests/helpers/Makemodule.am

./configure --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --runstatedir=/run   \
            --sbindir=/usr/sbin  \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3

make

chown -R tester .
su tester -c "make -k check"

make install

cd $LFS/sources
rm -Rf util-linux-2.39.3

#E2fsprogs-1.47.0
tar -xvf e2fsprogs-1.47.0.tar.gz
cd e2fsprogs-1.47.0

mkdir -v build
cd       build

../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make

make check

make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd $LFS/sources
rm -Rf e2fsprogs-1.47.0

#Stripping

save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
             libc.so.6
             libthread_db.so.1
             libquadmath.so.0.0.0
             libstdc++.so.6.0.32
             libitm.so.1.0.0
             libatomic.so.1.2.0"

cd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug --compress-debug-sections=zlib $LIB $LIB.dbg
    cp $LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

online_usrbin="bash find strip"
online_usrlib="libbfd-2.42.so
               libsframe.so.1.0.0
               libhistory.so.8.2
               libncursesw.so.6.4-20230520
               libm.so.6
               libreadline.so.8.2
               libz.so.1.3.1
               libzstd.so.1.5.5
               $(cd /usr/lib; find libnss*.so* -type f)"

for BIN in $online_usrbin; do
    cp /usr/bin/$BIN /tmp/$BIN
    strip --strip-unneeded /tmp/$BIN
    install -vm755 /tmp/$BIN /usr/bin
    rm /tmp/$BIN
done

for LIB in $online_usrlib; do
    cp /usr/lib/$LIB /tmp/$LIB
    strip --strip-unneeded /tmp/$LIB
    install -vm755 /tmp/$LIB /usr/lib
    rm /tmp/$LIB
done

for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
         $(find /usr/lib -type f -name \*.a)                 \
         $(find /usr/{bin,sbin,libexec} -type f); do
    case "$online_usrbin $online_usrlib $save_usrlib" in
        *$(basename $i)* )
            ;;
        * ) strip --strip-unneeded $i
            ;;
    esac
done

unset BIN LIB save_usrlib online_usrbin online_usrlib

#Cleaning up

rm -rf /tmp/*

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester