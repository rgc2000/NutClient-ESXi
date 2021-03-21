Network UPS Tools client for VMWare ESXi 5.0-7.0
------------------------------------------------

Author : Rene Garcia
Date   : 11-01-2021
Release: 2.1.2
Licence: GPL2

PURPOSE

Provide UPS connectivity to a single vSphere Hypervisor 5.0 to 7.0
Will shut down properly the host and vms with vmware-tools installed
if a NUT server tells that the power supply has gone and the UPS
battery level is critical.

INSTALL

- Enable SSH on the hypervisor.
- Copy via scp this TAR archive to /tmp directory of the hypervisor
- Connect via ssh to the hypervisor and type the followind commands

    cd /tmp
    tar -xzvf NutClient-ESXi-2.1.2.tar.gz
    ./upsmon-install.sh

- No need to reboot, upsmon can be started immediatly but you need
  to configure it first
- You can delete tmp files and disable SSH on the hypervisor

UPDATE

- Same as install but use ./upsmon-update.sh

UNINSTALL

- Same as install but use ./upsmon-remove.sh

CONFIGURATION

- Start vSphere Client and go to configuration tab of the hypervisor
- Open Advanced Parameters and go to UserVars
- Configure these parameters to match your needs :
   UserVars.NutUpsName    : UPS name on remote NUT server (ups_name@server_name), 
                            can be a space separated list of NUT servers
   UserVars.NutUser       : Username to connect to NUT server. If more that one NUT
                            server is declared, all need to use the same user/password
   UserVars.NutPassword   : Username password on NUT server
   UserVars.NutFinalDelay : Seconds to wait on low battery event before shutting down
   UserVars.NutSendMail   : Set to 1 if you want a mail to be sent on UPS event
   UserVars.NutMailTo     : Email address to send mail to on UPS event

- If you don't see UserVars parameters restart hostd service on
  hypervisor only if you have no vmware job running
    /etc/init.d/hostd restart
  You will need to reconnect with the client
- Now you can start and enable NUT client on hypervisor boot
- On configuration tab of the hypervisor go to Security Profile
- Open services properties
- Select Network UPS Tools client an click on Options

WARNINGS

This module is provided "as is" and is not approved by VMWare, you may 
lose VMWare support if you install it. Use it at your own risks.

REVISIONS

1.0.0 - 26/05/2012 - internal beta release
1.0.1 - 28/05/2012 - initial release
1.0.2 - 27/06/2012 - nut updated to version 2.6.4
1.1.0 - 23/02/2013 - nut updated to version 2.6.5 - messages to syslog
1.2.0 - 01/09/2013 - finaldelay is configurable - date in emails is RFC-2822 compliant
1.3.0 - 22/10/2014 - nut updated to version 2.7.2 - multi NUT servers support
1.4.0 - 16/04/2016 - nut updated to version 2.7.4 - SSL support with embeded libressl 2.3.0
2.0.0 - 27/01/2017 - compliant with community level on ESXi 6.x
2.0.1 - 23/05/2019 - set security policy for ESXi 6.7 update 2
2.1.0 - 26/05/2019 - libressl 2.9.2 - vib compatible with ISO integration
2.1.1 - 01/06/2020 - libressl 3.1.2 - fixed FROM value on smtp protocol for email notifications
2.1.2 - 11/01/2021 - libressl 3.2.3 - tested on ESXi 7.0
2.1.3 - 21/03/2021 - libressl 3.2.5
