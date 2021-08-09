#!/bin/bash -xe

${initial_commands}

exec 1> >(logger -s -t $(basename $0)) 2>&1

curl https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -o /tmp/epel-release-latest-8.noarch.rpm
rpm -qa | grep -q epel-release || yum install -y /tmp/epel-release-latest-8.noarch.rpm

#install awscliv2
dnf makecache
dnf -y install unzip
mkdir -p /tmp/awscliv2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2/awscliv2.zip"
unzip /tmp/awscliv2/awscliv2.zip -d /tmp/awscliv2/
./tmp/awscliv2/aws/install

ssm_running=$( ps -ef | grep [a]mazon-ssm-agent | wc -l )
if [[ $ssm_running != "0" ]]; then
    echo -e "amazon-ssm-agent already running"
    exit 0
else
    dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    ssm_running=$( ps -ef | grep [a]mazon-ssm-agent | wc -l )
    systemctl=$( command -v systemctl | wc -l )
    if [[ $systemctl != "0" ]]; then
        systemctl enable amazon-ssm-agent
        if [[ $ssm_running == "0" ]]; then
            systemctl start amazon-ssm-agent
        fi
    else
        if [[ $ssm_running == "0" ]]; then
            start amazon-ssm-agent
        fi
    fi
fi

${final_commands}
