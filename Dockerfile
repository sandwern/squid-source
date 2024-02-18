FROM alpine:3.19.1
RUN apk update
RUN set -x && \
apk add --no-cache \
openssl \
gcc \
g++ \
libc-dev \
gnupg \
openssl-dev>3 \
perl-dev \
autoconf \
automake \
make \
pkgconfig \
heimdal-dev \
libtool \
libcap-dev \
linux-headers \
openldap-dev \
bash
RUN mkdir /tmp/squid/
RUN cd /tmp/squid/
RUN wget http://www.squid-cache.org/Versions/v6/squid-6.7.tar.gz
RUN tar -xvf squid-6.7.tar.gz -C /tmp/squid/
RUN /tmp/squid/squid-6.7/configure --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 --libexecdir=/usr/libexec --sharedstatedir=/var/lib --mandir=/usr/share/man --infodir=/usr/share/info --exec_prefix=/usr --libexecdir=/usr/lib64/squid --localstatedir=/var --datadir=/usr/share/squid --sysconfdir=/etc/squid --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --disable-dependency-tracking --enable-follow-x-forwarded-for --enable-auth --enable-auth-basic=LDAP --enable-auth-ntlm=fake --enable-auth-digest=file,LDAP,eDirectory --enable-auth-negotiate=kerberos,wrapper --enable-external-acl-helpers=kerberos_ldap_group,LDAP_group,delayer,file_userip --enable-cache-digests --enable-cachemgr-hostname=localhost --enable-delay-pools --enable-epoll --enable-icap-client --enable-ident-lookups --enable-linux-netfilter --enable-removal-policies=heap,lru --enable-snmp --enable-ssl --enable-ssl-crtd --enable-storeio=aufs,diskd,ufs,rock --enable-diskio --enable-wccpv2 --enable-security-cert-generators --enable-security-cert-validators --with-aio --with-default-user=squid --with-filedescriptors=32768 --with-dl --with-openssl --with-pthreads --disable-arch-native --with-pic --without-nettle CFLAGS='-g -O2 -Wno-error' CXXFLAGS='-g -O2 -Wno-error'
RUN make -j$(nproc)
RUN make install
RUN cd /
RUN rm -rf /tmp/squid/*
RUN rm /squid-6.7.tar.gz
COPY ./source/squid.conf /etc/squid/squid.conf
COPY ./source/blocklists /etc/squid/blocklists
COPY ./source/openssl.cnf.add /etc/ssl
COPY ./source/start.sh /start.sh
RUN mkdir -p /var/cache/squid/
RUN chown -R squid:squid /var/cache/squid/
RUN cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf
RUN chmod +x /start.sh
EXPOSE 3128:3128/tcp
EXPOSE 4128:4128/tcp
CMD [ "/start.sh" ]
