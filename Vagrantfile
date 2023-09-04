Vagrant.configure("2") do |cfg|

  # The Domain Controller
  
    cfg.vm.define "rootdomaincontroller" do |config|
      config.vm.box = "StefanScherer/windows_2019"
      config.vm.network "private_network", ip:  "10.10.10.3" 
      config.winrm.transport = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.retry_limit = 120
      config.winrm.delay = 30
  
  
      config.vm.provider "virtualbox" do |v, override|
        v.name = "RootDC" 
        v.cpus = 2      
        v.memory = 8192 
        v.customize ["modifyvm", :id, "--vram",128] 
  
      end
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green Setting Hostname"
      config.vm.provision "shell", path: "automation_scripts/Change-Hostname.ps1", privileged: true, args: "-password vagrant -user vagrant -hostname RootDC"
      config.vm.provision "shell", reboot: true
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green Stopping Windows Updates ; stop-service wuauserv ; set-service wuauserv -startup disabled ; Write-Output Stooped_Updates"
      config.vm.provision "shell", inline: "Remove-WindowsFeature Windows-Defender"
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green Installing ad-domain-services ; install-windowsfeature -name 'ad-domain-services' -includemanagementtools"
      config.vm.provision "shell", reboot: true
      config.vm.provision "shell", path: "automation_scripts/Install-ADDSForest.ps1", privileged: true, args: " -localAdminpass P@ssworD123 -domainName evilcorp.local -domainNetbiosName evilcorp"
      config.vm.provision "shell", inline: "Start-Sleep -s 180"
      config.vm.provision "shell", reboot: true
      config.vm.provision "shell", inline: "Start-Sleep -s 60"
      config.vm.provision "shell", path: "automation_scripts/New-ADOUs-ADUsers.ps1" #new
  
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] RootDC Box Creation Over!"
    end
  
  # The workstation 2
    cfg.vm.define "workstation2" do |config| 
      config.vm.box = "StefanScherer/windows_10"
      config.vm.network "private_network", ip:  "10.10.10.102" 
      config.vm.boot_timeout = 1800
      config.winrm.transport = :plaintext
      config.winrm.basic_auth_only = true
      config.winrm.retry_limit = 30
      config.winrm.delay = 10
  
      config.vm.provider "virtualbox" do |v, override|
        v.name = "WS02" 
        v.cpus = 2      
        v.memory = 4096 
        v.customize ["modifyvm", :id, "--vram",128] 
      end
  
      config.vm.provision "shell", path: "automation_scripts/Change-Hostname.ps1", privileged: true, args: "-password vagrant -user vagrant -hostname WS02"
      config.vm.provision "shell", reboot: true
      config.vm.provision "shell", inline: "foreach ($c in Get-NetAdapter) { write-host 'Setting DNS for' $c.interfaceName ; Set-DnsClientServerAddress -InterfaceIndex $c.interfaceindex -ServerAddresses ('10.10.10.3', '10.10.10.3') }" 
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green ; Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False" , privileged: true
      config.vm.provision "shell", path: "automation_scripts/join-domain.ps1", privileged: true, args: "-Password  P@ssworD123 -user Administrator -domain evilcorp.local" 
      config.vm.provision "shell", reboot: true
      config.vm.provision "shell", path: "automation_scripts/Add-Aduser-to-localgroup.ps1", privileged: true, args: "-adduser eliot -group_add Administrators -domain 'evilcorp.local'"
      config.vm.provision "shell", path: "automation_scripts/Add-LocalUser.ps1", privileged: true, args: "-adduser tryell -password WinClient123 -group_add Administrators"
      config.vm.provision "shell", path: "automation_scripts/choco-get-apps.ps1", privileged: true, args: "vlc python3" # choco Script with Addidional Argutmet
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] Workstation-02 Box Creation Over!"
  
    end
  # The workstation 1
    cfg.vm.define "workstation1" do |config| 
        config.vm.box = "StefanScherer/windows_10"
        config.vm.network "private_network", ip:  "10.10.10.101"  
        config.vm.boot_timeout = 1800
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true
        config.winrm.retry_limit = 30
        config.winrm.delay = 10
  
        config.vm.provider "virtualbox" do |v, override|
          v.name = "WS01" 
          v.cpus = 2       
          v.memory = 4096 
          v.customize ["modifyvm", :id, "--vram",128] 
        end
  
        config.vm.provision "shell", inline: "echo -----------sysprep-things-----------------"
        config.vm.provision "shell", inline: <<-EOS
        $windowsCurrentVersion = Get-ItemProperty 'HKLM:/SOFTWARE/Microsoft/Windows NT/CurrentVersion'
        Write-Output "Windows name: $($windowsCurrentVersion.ProductName) $($windowsCurrentVersion.ReleaseId)"
        Write-Output "Windows version: $($windowsCurrentVersion.CurrentMajorVersionNumber).$($windowsCurrentVersion.CurrentMinorVersionNumber).$($windowsCurrentVersion.CurrentBuildNumber).$($windowsCurrentVersion.UBR)"
        Write-Output "Windows BuildLabEx version: $($windowsCurrentVersion.BuildLabEx)"
        EOS
        config.vm.provision "shell", inline: "Write-Output \"%COMPUTERNAME% before sysprep: $env:COMPUTERNAME\""
        config.vm.provision "shell", inline: "Get-WmiObject win32_useraccount | Select domain,name,sid"
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", inline: "Write-Output \"%COMPUTERNAME% after sysprep: $env:COMPUTERNAME\""
        config.vm.provision "shell", inline: "Get-WmiObject win32_useraccount | Select domain,name,sid"
        config.vm.provision "shell", inline: "echo -------------------Sysprep-Ends----------------------"
  
  
        config.vm.provision "shell", path: "automation_scripts/Change-Hostname.ps1", privileged: true, args: "-password vagrant -user vagrant -hostname WS01"
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", inline: "foreach ($c in Get-NetAdapter) { write-host 'Setting DNS for' $c.interfaceName ; Set-DnsClientServerAddress -InterfaceIndex $c.interfaceindex -ServerAddresses ('10.10.10.3', '10.10.10.3') }"
        config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green Turn of Firewall ; Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False" , privileged: true
        config.vm.provision "shell", path: "automation_scripts/join-domain.ps1", privileged: true, args: "-Password  P@ssworD123 -user Administrator -domain evilcorp.local" 
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", path: "automation_scripts/Add-LocalUser.ps1", privileged: true, args: "-adduser darlene -password W!nclient321 -group_add Administrators"
        config.vm.provision "shell", reboot: true
        config.vm.provision "shell", path: "automation_scripts/Add-Aduser-to-localgroup.ps1", privileged: true, args: "-adduser eliot -group_add Administrators -domain 'evilcorp.local'"
        config.vm.provision "shell", path: "automation_scripts/choco-get-apps.ps1", privileged: true, args: "netcat"
        config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] Workstation-01 Box Creation Over!"
  
      end
  
  
  
  # Running Final Commands
  
    cfg.vm.define "rootdomaincontroller" do |config| 
        config.vm.provision "shell", inline: "Write-Host -ForegroundColor Cyan [*] Final Commands [*]"
        config.vm.provision "shell", path: "automation_scripts/choco-get-apps.ps1", privileged: true
        config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] ROOTDC Box Cleaning OVER!!"
    end
  
    cfg.vm.define "workstation1" do |config| 
      
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Cyan [*] Final Commands [*]"
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] Workstation-01 Box Cleaning OVER!!"
    end
  
    cfg.vm.define "workstation2" do |config| 
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Cyan [*] Final Commands [*]"
      config.vm.provision "shell", inline: 'reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f'
      config.vm.provision "shell", inline: "Write-Host -ForegroundColor Green [+] Workstation-02 Box Cleaning OVER!!"
    end
  
  end
  