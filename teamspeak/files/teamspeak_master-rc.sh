#! /bin/sh
# teamspeak_master
# Maintainer: @tim
# Authors: @tim

# PROVIDE: teamspeak_master
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="teamspeak_master"
rcvar="teamspeak_master_enable"

load_rc_config teamspeak_master

: ${teamspeak_master_enable:="NO"}
: ${teamspeak_master_directory:={{ directory }}}
: ${teamspeak_master_user:={{ user }}}
: ${teamspeak_master_options:=""}

required_dirs=${teamspeak_master_directory}

pidfile=${teamspeak_master_directory}/ts3acc.pid
procname=${teamspeak_master_directory}/{{ executable }}
command=/usr/sbin/daemon
command_args="-p ${pidfile} -f ${procname} ${teamspeak_master_options}"

start_precmd="teamspeak_master_precmd"

teamspeak_master_precmd()
{
    install -o ${teamspeak_master_user} /dev/null ${pidfile}

    export PATH="${PATH}:/usr/local/bin:/usr/local/sbin"
    export LD_LIBRARY_PATH="${teamspeak_master_directory}:${LD_LIBRARY_PATH}"
    cd ${teamspeak_master_directory}
}

run_rc_command "$1"
