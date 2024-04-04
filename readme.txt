Network UPS Tools client for VMWare ESXi 5.0-8.0
------------------------------------------------

Author : Rene Garcia
Date   : 04-04-2024
Release: 2.6.2
Licence: GPLv3

PURPOSE

Provide UPS connectivity to a single vSphere Hypervisor 5.0 to 8.0
Will shut down properly the host and VMs with vmware-tools installed
if a NUT server tells that the power supply has gone and the UPS
battery level is critical.

INSTALL

The old way, for all ESXi versions from 5 to 8
- Enable SSH on the hypervisor.
- Copy via scp this TAR archive to /tmp directory on the hypervisor
- Connect via ssh to the hypervisor and type the followind commands

    cd /tmp
    tar -xzvf NutClient-ESXi-2.8.2-2.6.2.x86_64.tar.gz
    ./upsmon-install.sh

- No need to reboot, upsmon can be started immediatly but you need
  to configure it first
- You can delete tmp files and disable SSH on the hypervisor

The modern way, for ESXi 6 and above
- Enable SSH on the Hypervisor.
- Copy via scp the offline bundle ZIP file to /tmp directory on host
- Connect via ssh to the host and type the following command

    esxcli software vib install -d /tmp/NutClient-ESXi-2.8.2-2.6.2-offline_bundle.zip

UPDATE

- Same as install but use ./upsmon-update.sh
- Or use esxcli software vib update -d /tmp/NutClient-ESXi-2.8.2-2.6.2-offline_bundle.zip

UNINSTALL

- Same as install but use ./upsmon-remove.sh
- Or use esxcli software vib remove -n upsmon

CONFIGURATION

- Open ESXi UI web interface and log in. In 'navigator', select 'Manage' item in 'Host'
- In 'System' tab select 'Advanced Settings' and you can filter with "UserVars.Nut"
- Configure these parameters to match your needs :
   UserVars.NutUpsName        : UPS name on remote NUT server
                                (ups_name@server_name), can be a space
                                separated list of NUT servers.
   UserVars.NutUser           : Username to connect to NUT server.
                                If you are using more than one NUT server,
                                they all need to accept the same user/password.
   UserVars.NutPassword       : User password on NUT server.
   UserVars.NutFinalDelay     : Seconds to wait on low battery event
                                before shutting down.
   UserVars.NutOnBatteryDelay : Seconds to wait running on battery
                                before shutting down. Default is 0 to
                                disable this feature and wait for low
                                battery event before shutting down.
   UserVars.NutMinSupplies    : Number of power supplies needed to keep
                                the system running.
   UserVars.NutSendMail       : Set to 1 if you want a mail to be sent
                                on UPS events. Set to 2 for a more detailled
                                mail report with all UPS status. Set to 0 for no mail
   UserVars.NutMailTo         : Email address to send mail to on UPS events.
   UserVars.NutSmtpRelay      : Optional SMTP relay to send mail.
                                keep it empty for no relay (the default)

- If you don't see the UserVars parameters restart hostd service on
  hypervisor only if you have no vmware job running
    /etc/init.d/hostd restart
  You will need to reconnect with the client
- Now you can start and enable NUT client on hypervisor boot
- On ESXi UI web interface select 'Manage' item in 'Host'. The select 'Services' tab.
- Highlight NutClient service, in actions enable 'Start and stop with host' 
- Start the NutClient service once configured.
- Everytime you change a value in the UserVars you MUST restart NUT client service
  to reload the configuration.

WARNING

This module is provided "as is" and is not approved by VMWare, you may 
lose VMWare support if you install it. Use it at your own risks.

REVISIONS

Version notation is X.Y.Z where Z is for minor evolutions and bug fixes with no new
features. Y is for new features and X is for major evolutions with possible break of
ascending compatibility.

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
2.4.1 - 21/11/2022 - libressl 3.6.1 - Fix on battery delay shutdown with multiple ups setup
2.4.2 - 19/02/2023 - libressl 3.6.2
2.5.0 - 01/11/2023 - nut updated to version 2.8.1 - libressl 3.7.3 - UserVars description
2.6.0 - 17/11/2023 - new SMTP relay feature for mail notifications - verbose mail option
2.6.1 - 05/12/2023 - Fix default SMPT value to 'none' to be supported on ESXi 6.7 and previous
2.6.2 - 04/04/2024 - nut 2.8.2, libressl 2.9.1
