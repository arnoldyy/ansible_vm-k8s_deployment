#!/bin/bash

# k8s setup playbook
# Tested environment:
#   - collection: VM
#   - localhost OS Platform: WSL Ubuntu 20.04.2 LTS
#   - Ansible: core 2.16.3
#   - Python: 3.12.3
#   - pyvmomi: 8.0.2.0.1
#   - open-vm-tools
#   - ubuntu: 24.04 LTS
# 
# export ANSIBLE_CONFIG="$(dirname "$0")/ansible.cfg"
# ref: https://www.ludovicocaldara.net/dba/bash-tips-5-output-logfile/

dir_path=$(pwd)
# dir_path="/home/arnoldyeung/vm-k8s"

function log_open() {
    DATETIME=`date +"%Y%m%d_%H%M%S"`
    JOB=`basename $0 .sh`
    LOGDIR=$dir_path"/log"

    if [ ! -d $LOGDIR ]; then
        mkdir -p $LOGDIR
    else
        find $LOGDIR -name '*.pipe' -delete
        # log retention period
        find $LOGDIR -type f -mtime +30 -name '*.log' -delete
    fi
    Pipe=${LOGDIR}/${JOB}_${DATETIME}.pipe
    mkfifo -m 700 $Pipe
    LOGFILE=${LOGDIR}/${JOB}_${DATETIME}.log
    exec 3>&1 4>&2
    tee ${LOGFILE} <$Pipe >&3 &
    teepid=$!
    exec 1>$Pipe 2>&1
    PIPE_OPENED=1
}

function log_close() {
    if [ ${PIPE_OPENED} ] ; then
        exec 3<&4 2<&4 1<&3 3>&- 4>&-
        sleep 0.2
        ps --pid $teepid >/dev/null
        if [ $? -eq 0 ] ; then
            sleep 2
            kill  $teepid
        fi
        rm $Pipe
        unset PIPE_OPENED
    fi
}

function yes_no () {
    while true; do
        read -p "Type 'Yes' to confirm \"$1\". (yes/no)? " yn
        case $yn in
             yes ) break;;
             no ) exit;;
             * ) echo "Please answer 'yes' or no";;
        esac
    done
}

log_open
read -p "run ansible_deps/install_deps_virtual.sh to meet ansible env? (yes/no): " yn
if [[ $yn == "yes" ]]; then
    ./ansible_deps/install_deps.sh
else
    echo "Skipping virtual environment setup."
fi
source $dir_path"/ansible_deps/venv/bin/activate"
ansible-playbook $dir_path"/playbooks/vm_k8s_create.yml"
ansible-playbook $dir_path"/playbooks/kube_dependencies.yml" -K
ansible-playbook $dir_path"/playbooks/kube_master.yml" -K
ansible-playbook $dir_path"/playbooks/kube_workers.yml" -K
deactivate
log_close