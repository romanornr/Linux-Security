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

    # disable IP source routing
    sysctl net.ipv4.conf.all.accept_source_route=0
    
    # ignoring broadcasts request
    sysctl net.ipv4.icmp_echo_ignore_broadcasts=1

    # disable ICMP routing redirects
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0

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

main() {
    purge_telnet
    set_chkrootkit
    disable_compilers
    kernel_tuning
}

main "$@"
