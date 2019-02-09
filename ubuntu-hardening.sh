#!/bin/bash
#
# hardening Ubuntu

purge_telnet() {
    # Unless you need to it else remove it
    apt-get --yes purge telnet
}

set_chkrootkit() {
    apt-get --yes install chkrootkit
    chkrootkit
    }

disable_compilers() {
    chmod 000 /usr/bin/byacc
    chmod 000 /usr/bin/yacc
    chmod 000 /usr/bin/bcc
    chmod 000 /usr/bin/kgcc
    chmod 000 /usr/bin/cc
    chmod 000 /usr/bin/gcc
    chmod 000 /usr/bin/*c++
    chmod 000 /usr/bin/*g++
    # 755 to bring them back online
}

kernel_tuning() {
    sysctl kernel.randomize_va_space=1

    # enable IP spoofing protection
    sysctl net.ipv4.conf.all.rp_filter=1
    sysctl net.ipv4.conf.default.rp_filter=1

    # disable IP source routing
    sysctl net.ipv4.conf.all.accept_source_route=0

    # ignoring broadcasts request
    sysctl net.ipv4.icmp_echo_ignore_broadcasts=1

    sysctl net.ipv4.conf.all.secure_redirects=0

    sysctl net.ipv4.conf.default.secure_redirects=0

    sysctl net.ipv6.conf.default.accept_redirect=0

    sysctl net.ipv4.conf.all.send_redirects=0

    sysctl net.ipv4.conf.default.send_redirects=0

    sysctl net.ipv4.conf.all.accept_source_route=0

    sysctl net.ipv6.conf.all.accept_ra=0

    sysctl net.ipv6.conf.default.accept_ra=0

    #disable reaction to non RFC-1222 packets (prevent logs overflow)
    sysctl net.ipv4.icmp_ignore_bogus_error_responses=1

    echo "If you DO NOT use ipv6 you may want to disable it at all. \
          Would you like to do so?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) ; sysctl net.ipv6.conf.all.disable_ipv6=1 && \
                    sysctl net.ipv6.conf.default.disable_ipv6=1 && \
                    sysctl net.ipv6.conf.lo.disable_ipv6=1
            break;;
            No ) exit;;
        esac
    done

    # disable ICMP routing redirects
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.conf.default.accept_redirects = 0
    # disables the magic-sysrq key
    sysctl kernel.sysrq=0

    # turn off tcp_timestamps
    sysctl net.ipv4.tcp_timestamps=0

    # enable TCP SYN cookie protection
    sysctl net.ipv4.tcp_syncookies=1

    # enable bad message error detection
    sysctl net.ipv4.icmp_ignore_bogus_error_responses=1

    # reload new settings
    sysctl -p
}

mount_options {
  #set up corresponding mount options to /tmp /var/log/*
  grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev | grep ^[^\#] || sed -i 's"^\(.*\s/tmp\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nodev\2"g' /etc/fstab
  grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid | grep ^[^\#] || sed -i 's"^\(.*\s/tmp\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nosuid\2"g' /etc/fstab
  grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec | grep ^[^\#] || sed -i 's"^\(.*\s/tmp\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,noexec\2"g' /etc/fstab
  mount -o remount,noexec,nodev,nosuid /tmp

  grep "[[:space:]]/var/log[[:space:]]" /etc/fstab | grep nodev | grep ^[^#] || sed -i 's"^\(.*\s/var/log\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nodev\2"g' /etc/fstab
  grep "[[:space:]]/var/log[[:space:]]" /etc/fstab | grep nosuid | grep ^[^#] || sed -i 's"^\(.*\s/tmp\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nosuid\2"g' /etc/fstab
  grep "[[:space:]]/var/log[[:space:]]" /etc/fstab | grep noexec | grep ^[^#] || sed -i 's"^\(.*\s/var/log\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,noexec\2"g' /etc/fstab
  mount -o remount,noexec,nodev,nosuid /var/log
  grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab | grep nodev | grep ^[^#] || sed -i 's"^\(.*\s/var/log/audit\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nodev\2"g' /etc/fstab
  grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab | grep nosuid | grep ^[^#] || sed -i 's"^\(.*\s/var/log/audit\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nosuid\2"g' /etc/fstab
  grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab | grep noexec | grep ^[^#] || sed -i 's"^\(.*\s/var/log/audit\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,noexec\2"g' /etc/fstab
  mount -o remount,noexec,nodev,nosuid /var/log/audit

  grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev  | grep ^[^#] || sed -i 's"^\(.*\s/home\s\+\w\+\s\+[a-zA-Z0-9,]\+\)\(\s.*\)$"\1,nodev\2"g' /etc/fstab
  mount -o remount,nodev /home
}

main() {
    purge_telnet
    set_chkrootkit
    disable_compilers
    kernel_tuning
    mount_options
}

main "$@"
