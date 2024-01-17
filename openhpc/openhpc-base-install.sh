#!/bin/bash
YUM="yum -q -y"
sms_ip="$(nmcli device show eth1 | grep IP4.ADDRESS | awk '{print $NF}' | cut -d/ -f1)"
sed -ie "s/127.0.1.1/${sms_ip}/" /etc/hosts
echo "Yum updates"
${YUM} update --exclude='kernel*'
echo "OHPC repo"
${YUM} install http://repos.openhpc.community/OpenHPC/2/EL_8/x86_64/ohpc-release-2-1.el8.x86_64.rpm
${YUM} install dnf-plugins-core
${YUM} config-manager --set-enabled powertools
echo "OHPC docs install"
${YUM} install docs-ohpc perl
