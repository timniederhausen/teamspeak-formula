#! /bin/sh
# teamspeak_dns
# Maintainer: @tim
# Authors: @tim

# PROVIDE: teamspeak_dns
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="teamspeak_dns"
rcvar="teamspeak_dns_enable"

load_rc_config teamspeak_dns

: ${teamspeak_dns_enable:="NO"}
: ${teamspeak_dns_directory:={{ directory }}}
: ${teamspeak_dns_user:={{ user }}}
: ${teamspeak_dns_options:=""}

required_dirs=${teamspeak_dns_directory}

pidfile=${teamspeak_dns_directory}/ts3dns.pid
procname=${teamspeak_dns_directory}/{{ executable }}
command=/usr/sbin/daemon
command_args="-p ${pidfile} -f ${procname} ${teamspeak_dns_options}"

start_precmd="teamspeak_dns_precmd"

teamspeak_dns_precmd()
{
    install -o ${teamspeak_dns_user} /dev/null ${pidfile}

    export PATH="${PATH}:/usr/local/bin:/usr/local/sbin"
    export LD_LIBRARY_PATH="${teamspeak_dns_directory}:${LD_LIBRARY_PATH}"
    cd ${teamspeak_dns_directory}
}

run_rc_command "$1"
