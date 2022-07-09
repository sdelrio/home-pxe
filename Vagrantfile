Vagrant.configure("2") do |config|
  
$num_instances ||= 2
$instance_name_prefix ||= "client"

  config.vm.define :server do |server|

    # Use ubuntu 2004 for server
    server.vm.box = "generic/ubuntu2004"
    server.vm.hostname = "pxe-server"
    # Create a private network without vagrant DHCP
    server.vm.network "private_network",
      ip: "192.168.0.254",
      libvirt__network_name: "pxe",
      libvirt__dhcp_enabled: false

    # Configure VM
    server.vm.provider :libvirt do |libvirt|
      libvirt.cpu_mode = 'host-passthrough'
      libvirt.memory = '1024'
      libvirt.cpus = '1'
    end

    # Use ansible to install server
    server.vm.provision :ansible do |ansible|
      ansible.playbook = "playbook.yml"
    end

    config.vm.synced_folder ".", "/vagrant", disabled: false
  end

  (1..$num_instances).each do |i|
    # Disable autostart of client when "vagrant up"
    config.vm.define vm_name = "%s-%01d" % [$instance_name_prefix, i] do |client|
    #config.vm.define :client, autostart: true do |client|
      client.vm.hostname = "pxe-client-" % $i
      # Connect to private server private network
      client.vm.network "private_network",
        libvirt__network_name: "pxe",
        mac: "52:54:00:ae:34:%02d" % i
  
      # Configure VM
      client.vm.provider :libvirt do |libvirt|
        libvirt.cpu_mode = 'host-passthrough'
        libvirt.memory = '2048'
        libvirt.cpus = '2'
        # Create a disk
        libvirt.storage :file,
          size: '50G',
          type: 'qcow2',
          bus: 'sata',
          device: 'sda'
        # Set es keyboard for vnc connection
        libvirt.keymap = 'es'
        # Set pxe network NIC as default boot
        boot_network = {'network' => 'pxe'}
        libvirt.boot boot_network
        libvirt.boot 'hd'
        # Set UEFI boot, comment for legacy
        libvirt.loader = '/usr/share/qemu/OVMF.fd'
      end
    end
  end
end
