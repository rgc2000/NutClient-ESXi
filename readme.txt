Network UPS Tools client for VMWare ESXi 5.0-8.0
------------------------------------------------

Author : Rene Garcia
Date   : 23-10-2022
Release: 2.4.0
Licence: GPLv3

PURPOSE

Provide UPS connectivity to a single vSphere Hypervisor 5.0 to 8.0
Will shut down properly the host and vms with vmware-tools installed
if a NUT server tells that the power supply has gone and the UPS
battery level is critical.

INSTALL

- Enable SSH on the hypervisor.
- Copy via scp this TAR archive to /tmp directory of the hypervisor
- Connect via ssh to the hypervisor and type the followind commands

    cd /tmp
    tar -xzvf NutClient-ESXi-2.8.0-2.4.0.x86_64.tar.gz
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
   UserVars.NutUpsName        : UPS name on remote NUT server
                                (ups_name@server_name), can be a space
                                separated list of NUT servers.
   UserVars.NutUser           : Username to connect to NUT server.
                                If more that one NUT server is declared,
                                all need to use the same user/password
   UserVars.NutPassword       : Username password on NUT server.
   UserVars.NutFinalDelay     : Seconds to wait on low battery event
                                before shutting down.
   UserVars.NutOnBatteryDelay : Seconds to wait running on battery
                                before shutting down. Default is 0 to
                                disable this feature and wait for low
                                battery event before shutting down.
   UserVars.NutMinSupplies    : Number of power supplies needed to keep
                                the system running.
   UserVars.NutSendMail       : Set to 1 if you want a mail to be sent
                                on UPS events.
   UserVars.NutMailTo         : Email address to send mail to on UPS events.

- If you don't see UserVars parameters restart hostd service on
  hypervisor only if you have no vmware job running
    /etc/init.d/hostd restart
  You will need to reconnect with the client
- Now you can start and enable NUT client on hypervisor boot
- On configuration tab of the hypervisor go to Security Profile
- Open services properties
- Select Network UPS Tools client an click on Options
- When you change the values of the UserVars you MUST restart NUT client service
  to reload the configuration.

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
2.1.3 - 22/03/2021 - libressl 3.2.5
2.1.4 - 21/04/2021 - build also an offline depot for image builder, keep nut tools version
2.1.5 - 07/05/2021 - libressl 3.3.3
2.1.6 - 29/08/2021 - libressl 3.3.4
2.1.7 - 29/12/2021 - libressl 3.4.2
2.2.0 - 14/02/2022 - minsupplies is configurable
2.2.1 - 17/02/2022 - typo on parameter description
2.2.2 - 17/02/2022 - naming issue fixed in offline bundle, no changes in code
2.3.0 - 02/05/2022 - nut 2.8.0, libressl 3.5.2
2.3.1 - 23/08/2022 - libressl 2.5.3 - ESXi 8.0 support
2.3.2 - 19/10/2022 - ESXi 8.0 support, 64-bit binaries
2.4.0 - 23/10/2022 - New feature: Configurable shutdown delay when running on battery
