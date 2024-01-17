# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # SMS server
  config.vm.define "sms", primary: true do |sms|
    sms.vm.provider "virtualbox" do |vb|
      vb.memory = 8192
      vb.cpus = 4
    end
    sms.vm.box = "bento/rockylinux-8"
    sms.vm.hostname = "sms"
    sms.vm.network "private_network", ip: "172.16.0.1", netmask: "255.255.0.0", virtualbox__intnet: "XCBC"
    sms.vm.provision "shell", inline: <<-SHELL
      function add_if_missing() {
        if [ -f $2 ]; then
          grep -qFx $1 $2 || echo $1 >> $2
        fi
      }
      /vagrant/openhpc/openhpc-base-install.sh
      # export num_computes=2
      # export enable_mpi_defaults=0
      # c_mac[0]=08:00:27:00:00:01
      # c_mac[1]=08:00:27:00:00:02
      export OHPC_INPUT_LOCAL=/vagrant/openhpc/input.local
      echo "OHPC recipe.sh"
      /vagrant/openhpc/recipe.sh
      yum -y remove lmod-defaults-gnu12-openmpi4-ohpc-2.0-2.1.ohpc.2.6.noarch
      systemctl restart slurmctld
      yum -y install gcc-gfortran
      command -v module >& /dev/null && module purge
      srun --mpi=list
      export slurm_version=23.02.7
      # Rebuild slurm if needed
      for f in contribs- devel- example-configs- "" pam_slurm- perlapi- slurmctld- slurmdbd- slurmd-; do
        if [ ! -f /vagrant/slurm/slurm-${f}ohpc-${slurm_version}-9999.tntech.pmix.ohpc.1.x86_64.rpm ]; then
          /vagrant/slurm/build-slurm.sh
          cp /root/rpmbuild/RPMS/x86_64/*.rpm /vagrant/slurm
        fi
      done
      add_if_missing 'LaunchParameters=use_interactive_step' /etc/slurm/slurm.conf
      perl -pi.bak -e 's/MpiDefault=none/MpiDefault=pmix/ig' /etc/slurm/slurm.conf
      scontrol reconfigure

      ( cd /vagrant/slurm && yum -y localinstall slurm-{devel-,example-configs-,,perlapi-,slurmctld-,slurmd-,slurmdbd-}ohpc-${slurm_version}*.rpm )
      srun --mpi=list
      ( cd /vagrant/slurm && yum -y localinstall --installroot=/opt/ohpc/admin/images/rocky8.6/ slurm-{contribs-,example-configs-,,pam_slurm-,slurmd-}ohpc-${slurm_version}-9999.tntech.pmix.ohpc.1.x86_64.rpm )
      chroot /opt/ohpc/admin/images/rocky8.6 systemctl enable slurmd
      wwvnfs --chroot=/opt/ohpc/admin/images/rocky8.6/
      yum -y install platform-python-devel libevent-devel
    SHELL
    sms.vm.provision "shell", privileged: false, inline: <<-SHELLUNPRIV
      # command -v module >& /dev/null && module purge
      # SPACK_VER=v0.21.1
      # mkdir -p ~/spack/${SPACK_VER}
      # git clone -c feature.manyFiles=true https://github.com/spack/spack.git ~/spack/git
      # ( cd ~/spack/git && git archive --format=tar ${SPACK_VER} | tar -C ../${SPACK_VER} -xf - )
      # cp /vagrant/packages.yaml ~/spack/${SPACK_VER}/etc/spack
      # perl -pi.bak -e "
      #   s/slurm\@.*/slurm\@$(rpm -q --qf '%{VERSION}' slurm-slurmctld-ohpc)/g;
      #   s/pmix\@.*/pmix\@$(rpm -q --qf '%{VERSION}' pmix-ohpc)/g;
      #   s/libevent\@.*/libevent\@$(rpm -q --qf '%{VERSION}' libevent-devel)/g;
      #   " ~/spack/${SPACK_VER}/etc/spack/packages.yaml
      # . ~/spack/${SPACK_VER}/share/spack/setup-env.sh
      # spack compiler find --scope=site
      # spack install -j4 --reuse openmpi+legacylaunchers schedulers=slurm fabrics=ucx ^pmix@4.2.1
      #spack load openmpi
      #ompi_info
    SHELLUNPRIV
  end

  # Compute servers
  (1..2).each do |compute_idx|
    config.vm.define "c#{compute_idx}", autostart: false do |compute|
      compute.vm.box = "clink15/pxe"
      compute.vm.network "private_network", virtualbox__intnet: "XCBC", mac: "08002700000#{compute_idx}", auto_config: false
      compute.ssh.insert_key = false
      compute.ssh.connect_timeout = 1
      compute.vm.allow_fstab_modification = false
      compute.vm.allow_hosts_modification = false
      compute.vm.boot_timeout = 1
      compute.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--nicbootprio2", "1"]
        vb.memory = "4096"
        vb.cpus = 2
      end
      compute.vm.synced_folder ".", "/vagrant", disabled: true
    end
  end

end
