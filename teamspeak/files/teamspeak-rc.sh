#! /bin/sh
# teamspeak
# Maintainer: @tim
# Authors: @tim

# PROVIDE: teamspeak
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="teamspeak"
rcvar="teamspeak_enable"

load_rc_config teamspeak

: ${teamspeak_enable:="NO"}
: ${teamspeak_directory:={{ directory }}}
: ${teamspeak_user:={{ user }}}
: ${teamspeak_options:="inifile=ts3server.ini"}

required_dirs=${teamspeak_directory}

pidfile=${teamspeak_directory}/ts3server.pid
procname=${teamspeak_directory}/{{ executable }}
command=/usr/sbin/daemon
command_args="-p ${pidfile} -f ${procname} ${teamspeak_options} license_accepted=1"

start_precmd="teamspeak_precmd"

teamspeak_precmd()
{
    load_kld aio

    install -o ${teamspeak_user} /dev/null ${pidfile}

    export PATH="${PATH}:/usr/local/bin:/usr/local/sbin"
    export LD_LIBRARY_PATH="${teamspeak_directory}:/usr/local/lib/mariadb:${LD_LIBRARY_PATH}"
    cd ${teamspeak_directory}
}

run_rc_command "$1"
