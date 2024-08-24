#!/bin/bash
# 配置rsyslog，udp发送
# 适用：RHEL6、7、8/CentOS6、7、8/BCLinux7、8/BCLinux-For-Euler21、22，在RHEL5/CentOS5/SuSE11、12评估使用
# 查找【依实际修改】的变量，根据实际修改
# 注意：RHEL5/CentOS5会停用syslog[service syslog stop]，再启用rsyslog[service rsyslog start]


# 日志采集节点IP地址，依实际修改
#collector_ip='10.155.32.11'
# 日志采集节点端口，依实际修改
#collector_port='2514'

# rsyslog的版本，rsyslogd_v 默认为空
rsyslogd_v=''
# 发送syslog_udp的配置文件，建议默认（新版取消使用此文件，直接使用/etc/rsyslog.conf，默认即可）
syslog_conf_path='/etc/rsyslog.d/send_syslog_udp.conf'


# 在/etc/bashrc追加自定义PROMPT_COMMAND变量
func_PROMPT_COMMAND(){
    echo "------------------------------------------------------------------------------------------------------"
    bash_rc="/etc/bashrc"
    if [[ ! -f "${bash_rc}" ]]; then bash_rc="/etc/bash.bashrc"; fi
    # PROMPT_COMMAND 是一个环境变量，用于定义在显示 Bash 提示符之前要执行的命令。当设置了 PROMPT_COMMAND 环境变量后，每次显示 Bash 提示符时，都会自动执行该变量中定义的命令。
    if [[ -f "${bash_rc}" ]]; then
        p_cmd=$(cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND' | grep 'history 1' | grep 'logger -p local3.info')
        if [[ -z "${p_cmd}" ]]; then
            # export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; }); logger -p local3.info  \[ $(who am i)\]\# \""${msg}"\"; }'
            echo -e 'export PROMPT_COMMAND=\x27{ msg=$(history 1 | { read x y; echo $y; }); logger -p local3.info  \[ $(who am i)\]\# \""${msg}"\"; }\x27' >> "${bash_rc}"
            echo "添加配置[cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND']"
            cat "${bash_rc}" | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND'
        else
            echo "已有配置[cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND']"
            cat "${bash_rc}" | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND'
        fi
    else
        echo "不存在[${bash_rc}]"
    fi
    echo "------------------------------------------------------------------------------------------------------"
}

# 在/etc/bashrc取消自定义PROMPT_COMMAND变量
unset_PROMPT_COMMAND(){
    echo "------------------------------------------------------------------------------------------------------"
    bash_rc="/etc/bashrc"
    if [[ ! -f "${bash_rc}" ]]; then bash_rc="/etc/bash.bashrc"; fi
    # PROMPT_COMMAND 是一个环境变量，用于定义在显示 Bash 提示符之前要执行的命令。当设置了 PROMPT_COMMAND 环境变量后，每次显示 Bash 提示符时，都会自动执行该变量中定义的命令。
    if [[ -f "${bash_rc}" ]]; then
        p_cmd=$(cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND' | grep 'history 1' | grep 'logger -p local3.info')
        if [[ -n "${p_cmd}" ]]; then
            # export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; }); logger -p local3.info  \[ $(who am i)\]\# \""${msg}"\"; }'
            sed -i '/^export PROMPT_COMMAND=.*history 1.*logger -p local3.info.*$/d' "${bash_rc}"
            echo "取消配置[cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND']"
            cat "${bash_rc}" | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND'
        else
            echo "没有配置[cat ${bash_rc} | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND']"
            cat "${bash_rc}" | grep -vE '^(\s*#|$)' | grep '^export PROMPT_COMMAND'
        fi
    else
        echo "不存在[${bash_rc}]"
    fi
    echo "------------------------------------------------------------------------------------------------------"
}


# 在/etc/profile追加自定义log2syslog函数
func_etc_profile(){
    echo "------------------------------------------------------------------------------------------------------"
    pro_file="/etc/profile"
    fun_name=$(cat ${pro_file} | grep -vE '^(\s*#|$)' | grep '^function log2syslog(){$')
    fun_exec=$(cat ${pro_file} | grep -vE '^(\s*#|$)' | grep '^trap log2syslog DEBUG$')

# ·trap log2syslog DEBUG·意为对shell中的每一个activity都执行一遍log2syslog函数
if [[ -z "${fun_name}" && -z "${fun_exec}" ]]; then
# if [[ 'printf "\033]0;%s@%s:%s\007" "\${USER}" "\${HOSTNAME%%.*}" "\${PWD/#\$HOME/~}"' != "\$BASH_COMMAND" ]]; then
cat >> "${pro_file}" << EOF

function log2syslog(){
    # 过滤PS命令执行(每次执行都有) 或者采用 PROMPT_COMMAND 系统变量代替下面
    if [[ "\${PROMPT_COMMAND}" != "\$BASH_COMMAND" ]]; then
        logger -p local3.info -t COMMAND -i "\${SSH_CONNECTION} - \${USER} - \${PWD} - \${BASH_COMMAND}"
    fi
}
trap log2syslog DEBUG
EOF

    echo "添加 log2syslog 函数[sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' ${pro_file}]"
    sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' "${pro_file}"
else
    echo "已有 log2syslog 函数[sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' ${pro_file}]"
    sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' "${pro_file}"
fi
    echo "------------------------------------------------------------------------------------------------------"
}

# 在/etc/profile取消自定义log2syslog函数
unset_etc_profile(){
    echo "------------------------------------------------------------------------------------------------------"
    pro_file="/etc/profile"
    fun_name=$(cat ${pro_file} | grep -vE '^(\s*#|$)' | grep '^function log2syslog(){$')
    fun_exec=$(cat ${pro_file} | grep -vE '^(\s*#|$)' | grep '^trap log2syslog DEBUG$')

    # ·trap log2syslog DEBUG·意为对shell中的每一个activity都执行一遍log2syslog函数
    if [[ -n "${fun_name}" && -n "${fun_exec}" ]]; then
        sed -i '/function log2syslog/,/trap log2syslog DEBUG/d' "${pro_file}"
        echo "删除 log2syslog 函数[sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' ${pro_file}]"
        sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' "${pro_file}"
    else
        echo "没有 log2syslog 函数[sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' ${pro_file}]"
        sed -n '/function log2syslog/,/trap log2syslog DEBUG/p' "${pro_file}"
    fi
    echo "------------------------------------------------------------------------------------------------------"
}


# 配置crontab发送lastlog
func_lastlog_cron(){
    echo "------------------------------------------------------------------------------------------------------"
    logger_cron=$(crontab -l | grep -vE '^(\s*#|$)' | grep 'lastlog' | grep 'logger')
    if [[ -z "${logger_cron}" ]]; then
        # 发送lastlog的crontab执行周期，依实际修改
        log_cron="1 * * * *"
        # 待添加的rontab
        #lastlog_cmd="${log_cron} lastlog | grep -v '\*\*' | grep -v 'Username' | grep -v '用户名' | xargs logger -p local3.info -t LASTLOG -i"
        lastlog_cmd="${log_cron} lastlog | grep -v '\*\*' | grep -v 'Username' | grep -v '用户名' | awk -F'\n' '{for(i=1; i<=NF; i++) {item=\$i; cmd=\"logger -p local3.info -t LASTLOG -i \" item; system(cmd)}}'"
        # echo "${lastlog_cmd}"
        # crontab新增一行，执行lastlog，并发送syslog的local3.info
        crontab -l > temp_cron
        echo "${lastlog_cmd}" >> temp_cron
        crontab temp_cron
        rm -rf temp_cron
        echo "添加配置crontab发送lastlog[crontab -l]"
        crontab -l
    else
        echo "已有配置crontab发送lastlog[crontab -l]"
        crontab -l
    fi
    echo "------------------------------------------------------------------------------------------------------"
}

# 取消crontab发送lastlog
unset_lastlog_cron(){
    echo "------------------------------------------------------------------------------------------------------"
    logger_cron=$(crontab -l | grep -vE '^(\s*#|$)' | grep 'lastlog' | grep 'logger')
    if [[ -n "${logger_cron}" ]]; then
        # 备份现有crontab
        crontab -l > temp_cron
        # 删除crontab发送lastlog
        #sed -i '/.* lastlog .* xargs logger -p local3.info .*i$/d' temp_cron
        sed -i '/.* lastlog .*logger -p local3.info /d' temp_cron
        # 恢复删除crontab发送lastlog的crontab
        crontab temp_cron
        # 删除临时文件
        rm -rf temp_cron
        echo "取消配置crontab发送lastlog[crontab -l]"
        crontab -l
    else
        echo "没有配置crontab发送lastlog[crontab -l]"
        crontab -l
    fi
    echo "------------------------------------------------------------------------------------------------------"
}


# syslog_udp发送配置
func_set_syslog_udp(){
    echo "------------------------------------------------------------------------------------------------------"
    # 移除旧版配置
    if [[ -f "${syslog_conf_path}" ]]; then mv "${syslog_conf_path}" /tmp; fi

    # 自定义操作日志记录文件，路径[/var/log/]
    terminal_log_path='/var/log/user_command.log'

    syslog_conf="/etc/rsyslog.conf"
    add_conf=$(sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' ${syslog_conf})

# 配置追加/etc/rsyslog.conf文件
if [[ -z "${add_conf}" ]]; then
cat >> "${syslog_conf}" << EOF

local3.info  ${terminal_log_path}
local3.info  @${collector_ip}:${collector_port}
authpriv.*   @${collector_ip}:${collector_port}
EOF
fi

    # 创建操作日志记录文件
    if [[ ! -f "${terminal_log_path}" ]]; then touch "${terminal_log_path}"; chmod 644 "${terminal_log_path}"; fi

    echo "查看配置[sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' ${syslog_conf}]"
    sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' "${syslog_conf}"
    echo -e "\n自定义操作日志记录文件[ls -l ${terminal_log_path}]"
    ls -l "${terminal_log_path}"
    echo "------------------------------------------------------------------------------------------------------"
}

# syslog_udp取消配置
unset_set_syslog_udp(){
    echo "------------------------------------------------------------------------------------------------------"
    # 移除旧版配置
    if [[ -f "${syslog_conf_path}" ]]; then mv "${syslog_conf_path}" /tmp; fi

    # 自定义操作日志记录文件，路径[/var/log/]
    terminal_log_path='/var/log/user_command.log'

    syslog_conf="/etc/rsyslog.conf"
    add_conf=$(sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' ${syslog_conf})

    # 取消配置追加/etc/rsyslog.conf文件
    if [[ -n "${add_conf}" ]]; then
        sed -i '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/d' "${syslog_conf}"
    fi

    # 移除操作日志记录文件
    if [[ -f "${terminal_log_path}" ]]; then mv "${terminal_log_path}"* /tmp; fi

    echo "查看配置[sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' ${syslog_conf}]"
    sed -n '/^local3\.info  .*user_command.log$/,/^authpriv\.\*   \@.*[0-9]$/p' "${syslog_conf}"
    echo -e "\n自定义操作日志记录文件[ls -l ${terminal_log_path}]"
    ls -l "${terminal_log_path}"
    echo "------------------------------------------------------------------------------------------------------"
}


# 添加logrotate配置
func_set_logrotate(){
    echo "------------------------------------------------------------------------------------------------------"
    log_rotate=''
    if [[ -f '/etc/logrotate.d/syslog' ]]; then
        log_rotate='/etc/logrotate.d/syslog'
    elif [[ -f '/etc/logrotate.d/rsyslog' ]]; then
        log_rotate='/etc/logrotate.d/rsyslog'
    else
        echo "logrotate无syslog配置"
    fi

    cmd_set=$(cat "${log_rotate}" | grep '^/var/log/user_command.log$')
    # 添加配置
    if [[ -n "${log_rotate}" && -z "${cmd_set}" ]]; then
        sed -i '/{/i\/var/log/user_command.log' "${log_rotate}"
        echo "添加配置[cat ${log_rotate}]"
        cat "${log_rotate}"
    else
        echo "已有/var/log/user_command.log配置[cat ${log_rotate}]"
        cat "${log_rotate}"
    fi

    # 重新加载logrotate配置文件
    if [[ -n "${log_rotate}" ]]; then logrotate /etc/logrotate.conf; fi
    echo "------------------------------------------------------------------------------------------------------"
}

# 取消logrotate配置
unset_set_logrotate(){
    echo "------------------------------------------------------------------------------------------------------"
    log_rotate=''
    if [[ -f '/etc/logrotate.d/syslog' ]]; then
        log_rotate='/etc/logrotate.d/syslog'
    elif [[ -f '/etc/logrotate.d/rsyslog' ]]; then
        log_rotate='/etc/logrotate.d/rsyslog'
    else
        echo "logrotate无syslog配置"
    fi

    cmd_set=$(cat "${log_rotate}" | grep '^/var/log/user_command.log$')
    # 取消配置
    if [[ -n "${log_rotate}" && -n "${cmd_set}" ]]; then
        sed -i '/\/var\/log\/user_command\.log/d' "${log_rotate}"
        echo "取消配置[cat ${log_rotate}]"
        cat "${log_rotate}"
    else
        echo "没有/var/log/user_command.log配置[cat ${log_rotate}]"
        cat "${log_rotate}"
    fi

    # 重新加载logrotate配置文件
    if [[ -n "${log_rotate}" ]]; then logrotate /etc/logrotate.conf; fi
    echo "------------------------------------------------------------------------------------------------------"
}


# 查看操作系统信息
func_system_v(){
    echo "------------------------------------------------------------------------------------------------------"
    if [[ -f "/etc/system-release" ]]; then
        echo "操作系统版本：$(cat /etc/system-release)"
    elif [[ -f "/etc/redhat-release" ]]; then
        echo "操作系统版本：$(cat /etc/redhat-release)"
    elif [[ -f "/etc/SuSE-release" ]]; then
        echo "操作系统版本：$(cat /etc/SuSE-release)"
    else
        echo "操作系统版本：未知"
    fi
    echo "操作系统内核：$(uname -a)"
    echo "------------------------------------------------------------------------------------------------------"
}


# 重启rsyslog服务
func_restart_rsyslog(){
    echo "------------------------------------------------------------------------------------------------------"
    if [[ -f "/usr/bin/systemctl"  ]]; then
        echo -e "\n[systemctl enable rsyslog]"
        systemctl enable rsyslog
        echo -e "\n[systemctl restart rsyslog]"
        systemctl restart rsyslog
        echo -e "\n[systemctl status rsyslog]"
       # systemctl status rsyslog
    elif [[ -f "/sbin/service" || -f "/usr/sbin/service"  ]]; then
        if [[ -f "/etc/syslog.conf" ]]; then
            echo -e "\n[service syslog stop]"
            service syslog stop
            echo -e "\n[chkconfig syslog off]"
            chkconfig syslog off

            echo -e "\n[chkconfig rsyslog on]"
            chkconfig rsyslog on
            echo -e "\n[service rsyslog restart]"
            service rsyslog restart
            echo -e "\n[service rsyslog status]"
            service rsyslog status

            echo -e "\n[chkconfig --list | grep syslog]"
            chkconfig --list | grep syslog
        elif [[ -f "/etc/rsyslog.conf" ]]; then
            echo -e "\n[chkconfig rsyslog on]"
            chkconfig rsyslog on
            echo -e "\n[service rsyslog restart]"
            service rsyslog restart
            echo -e "\n[service rsyslog status]"
            service rsyslog status

            echo -e "\n[chkconfig --list | grep syslog]"
            chkconfig --list | grep syslog
        fi
    else
        echo "未找到[systemctl/service]命令"
    fi
    echo "------------------------------------------------------------------------------------------------------"
}

# 取消配置重启rsyslog服务
unset_restart_rsyslog(){
    echo "------------------------------------------------------------------------------------------------------"
    if [[ -f "/usr/bin/systemctl"  ]]; then
        echo -e "\n[systemctl enable rsyslog]"
        systemctl enable rsyslog
        echo -e "\n[systemctl restart rsyslog]"
        systemctl restart rsyslog
        echo -e "\n[systemctl status rsyslog]"
        systemctl status rsyslog
    elif [[ -f "/sbin/service" || -f "/usr/sbin/service"  ]]; then
        if [[ -f "/etc/syslog.conf" ]]; then
            echo -e "\n[chkconfig rsyslog off]"
            chkconfig rsyslog off
            echo -e "\n[service rsyslog stop]"
            service rsyslog stop
            echo -e "\n[service rsyslog status]"
            service rsyslog status

            echo -e "\n[service syslog restart]"
            service syslog restart
            echo -e "\n[chkconfig syslog on]"
            chkconfig syslog on
            echo -e "\n[service syslog status]"
            service syslog status

            echo -e "\n[chkconfig --list | grep syslog]"
            chkconfig --list | grep syslog
        elif [[ -f "/etc/rsyslog.conf" ]]; then
            echo -e "\n[chkconfig rsyslog on]"
            chkconfig rsyslog on
            echo -e "\n[service rsyslog restart]"
            service rsyslog restart
            echo -e "\n[service rsyslog status]"
            service rsyslog status

            echo -e "\n[chkconfig --list | grep syslog]"
            chkconfig --list | grep syslog
        fi
    else
        echo "未找到[systemctl/service]命令"
    fi
    echo "------------------------------------------------------------------------------------------------------"
}


# 查看rsyslog版本
func_rsyslogd_v(){
    echo "------------------------------------------------------------------------------------------------------"
    if [[ -f "/usr/sbin/rsyslogd" || -f "/sbin/rsyslogd"  ]]; then
        # rsyslogd_v=$(rsyslogd -v | grep 'rsyslogd ' | awk '{print $2}' | cut -d'.' -f 1)
        rsyslogd_v=$(rsyslogd -v | grep 'rsyslogd ' | awk '{print $2}')
        echo "rsyslogd:[${rsyslogd_v}]"
    else
        echo "未找到[rsyslogd]命令，请检查rsyslog服务"
        exit 0
    fi
    echo "------------------------------------------------------------------------------------------------------"
}


# 配置并重启rsyslog
func_setup(){
    ## 查看rsyslog版本
    echo -e "\n查看rsyslog版本"
    func_rsyslogd_v

    if [[ -n "${rsyslogd_v}" ]]; then
        ## 查看操作系统信息
        echo -e "\n查看操作系统信息"
        func_system_v

        ## 在/etc/bashrc追加自定义PROMPT_COMMAND变量 func_PROMPT_COMMAND与func_etc_profile二选一
         #echo -e "\n在/etc/bashrc追加自定义PROMPT_COMMAND变量"
         #func_PROMPT_COMMAND
        ## 在/etc/profile追加自定义log2syslog函数 func_PROMPT_COMMAND与func_etc_profile二选一
        echo -e "\n在/etc/profile追加自定义log2syslog函数"
        func_etc_profile

        ## 配置crontab发送lastlog
        echo -e "\n配置crontab发送lastlog"
        func_lastlog_cron

        ## syslog_udp发送配置
        echo -e "\nsyslog_udp发送配置"
        func_set_syslog_udp

        ## 添加logrotate配置
        echo -e "\n添加logrotate配置"
        func_set_logrotate

        ## 重启rsyslog服务
        echo -e "\n重启rsyslog服务"
        func_restart_rsyslog
    else
        echo "未找到[rsyslogd]"
    fi
}


# 取消配置并重启rsyslog
func_unset(){
    ## 查看rsyslog版本
    echo -e "\n查看rsyslog版本"
    func_rsyslogd_v

    if [[ -n "${rsyslogd_v}" ]]; then
        ## 查看操作系统信息
        echo -e "\n查看操作系统信息"
        func_system_v

        ## 在/etc/bashrc取消自定义PROMPT_COMMAND变量 func_PROMPT_COMMAND与func_etc_profile二选一
         #echo -e "\n在/etc/bashrc取消自定义PROMPT_COMMAND变量"
         #unset_PROMPT_COMMAND
        ## 在/etc/profile取消自定义log2syslog函数 func_PROMPT_COMMAND与func_etc_profile二选一
        echo -e "\n在/etc/profile取消自定义log2syslog函数"
        unset_etc_profile

        ## 取消crontab发送lastlog
        echo -e "\n取消crontab发送lastlog"
        unset_lastlog_cron

        ## syslog_udp取消配置
        echo -e "\nsyslog_udp取消配置"
        unset_set_syslog_udp

        ## 取消logrotate配置
        echo -e "\n取消logrotate配置"
        unset_set_logrotate

        ## 取消配置重启rsyslog服务
        echo -e "\n重启rsyslog服务"
        unset_restart_rsyslog
    else
        echo "未找到[rsyslogd]"
    fi
}


# 脚本执行参数
option="${1}"
case ${option} in
    log_setup)
        # 配置并重启rsyslog
        func_setup
        ;;
    log_unset)
        # 取消配置并重启rsyslog
        func_unset
        ;;
    re_setup)
        # 取消配置并重启rsyslog
        func_unset
        # 配置并重启rsyslog
        func_setup
        ;;
    *)
        echo "# 配置rsyslog，udp发送"
        echo "# 适用：RHEL6、7、8/CentOS6、7、8/BCLinux7、8/BCLinux-For-Euler21、22，在RHEL5/CentOS5/SuSE11、12评估使用"
        echo "# 查找【依实际修改】的变量，根据实际修改"
        echo "# 注意：RHEL5/CentOS5会停用syslog[service syslog stop]，再启用rsyslog[service rsyslog start]"
        echo -e "\nUsage: sh $0 [log_setup|log_unset|re_setup]"
        echo "参数说明："
        echo -e "\tlog_setup：添加配置"
        echo -e "\tlog_unset：取消配置"
        echo -e "\tre_setup ：先取消配置，再添加配置"
        ;;
esac

