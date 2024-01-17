#!/bin/bash

export V=${slurm_version:-22.05.10}
export YUM=${YUM:-"yum -y"}
mkdir -p /root/rpmbuild/{SOURCES,SPECS}
${YUM} install \
    'pkgconfig(lua)' \
    dbus-devel \
    gtk2-devel \
    http-parser-devel \
    hwloc-libs \
    json-c-devel \
    libcurl-devel \
    mariadb-devel \
    munge-devel \
    numactl-devel \
    ohpc-buildroot \
    openssl-devel \
    pam-devel \
    pmix-ohpc \
    readline-devel \
    rpm-build
command -v module >& /dev/null && module purge
( cd /root/rpmbuild/SOURCES && \
    wget --no-clobber https://raw.githubusercontent.com/openhpc/ohpc/3.x/components/OHPC_macros && \
    wget --no-clobber https://download.schedmd.com/slurm/slurm-${V}.tar.bz2 && \
    wget --no-clobber https://raw.githubusercontent.com/openhpc/ohpc/2.x/components/rms/slurm/SOURCES/slurm.epilog.clean && \
    wget --no-clobber https://raw.githubusercontent.com/openhpc/ohpc/2.x/components/rms/slurm/SOURCES/slurm.rpmlintrc )
( cd /root/rpmbuild/SPECS && \
    wget --no-clobber https://raw.githubusercontent.com/openhpc/ohpc/2.x/components/rms/slurm/SPECS/slurm.spec && \
    wget --no-clobber https://raw.githubusercontent.com/openhpc/ohpc/2.x/components/rms/slurm/SPECS/spec.latest.patch && \
    perl -pi.bak -e "s/Version:\s+[[:digit:]-\.]+/Version: ${V}/g;s/#global _with_pmix/%global _with_pmix/g" slurm.spec && \
    rpmbuild --define "dist 9999.tntech.pmix.ohpc" --with pmix -bb slurm.spec )
cp /root/rpmbuild/RPMS/x86_64/slurm-{devel-,example-configs-,,perlapi-,slurmctld-,slurmdbd-}ohpc-${V}*.x86_64.rpm /vagrant/slurm
# ( cd /root/rpmbuild/RPMS/x86_64 && \
#     yum -y localinstall \
#     slurm-{devel-,example-configs-,,perlapi-,slurmctld-,slurmdbd-}ohpc-${V}*.x86_64.rpm )
# systemctl restart slurmctld
