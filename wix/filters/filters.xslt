<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                          xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                          xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">
  <!-- https://ahordijk.wordpress.com/2013/03/26/automatically-add-references-and-content-to-the-wix-installer/ -->
  <!-- http://www.chriskonces.com/using-xslt-with-heat-exe-wix-to-create-windows-service-installs/ -->
  <xsl:output method="xml" indent="yes" />
  <!--<xsl:strip-space elements="*"/>-->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- when the ruby.exe filter matches, do nothing -->
  <xsl:template match="wix:Component[wix:File[@Source='$(var.StageDir)\ruby\bin\ruby.exe']]" >
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <Component Id='PuppetServiceAutomatic' Guid="639ECD7F-6186-43D5-9E1A-FC0278DBEE15" Win64="$(var.Win64)">
          <Condition>
            <![CDATA[ (PUPPET_AGENT_STARTUP_MODE ~<> "manual") AND (PUPPET_AGENT_STARTUP_MODE ~<> "disabled") ]]>
          </Condition>
          <File Id="RubyExeAutomatic" KeyPath="yes" Source="$(var.StageDir)\sys\ruby\bin\ruby.exe" />
          <ServiceInstall Id="ServiceInstaller"
                                   Account="[PUPPET_AGENT_ACCOUNT_DOMAIN]\[PUPPET_AGENT_ACCOUNT_USER]"
                                   Password="[PUPPET_AGENT_ACCOUNT_PASSWORD]"
                                   Description="Periodically fetches and applies configurations from a Puppet master server."
                                   DisplayName="Puppet Agent"
                                   Interactive="no"
                                   Name="$(var.PuppetServiceName)"
                                   Start="auto"
                                   Type="ownProcess"
                                   ErrorControl="normal"
                                   Vital="yes"
                                   Arguments="-rubygems &quot;[INSTALLDIR]service\daemon.rb&quot;" />
          <ServiceControl Id="ServiceControlOptions"
                                      Start="install"
                                      Stop="both"
                                      Remove="uninstall"
                                      Name="$(var.PuppetServiceName)"
                                      Wait="yes" />
      </Component>
      <Component Id='PuppetServiceManual' Guid="752A5A25-9619-4EBA-AA8B-12D8C8688236" Win64="$(var.Win64)">
        <Condition>
          <![CDATA[PUPPET_AGENT_STARTUP_MODE ~= "manual"]]>
        </Condition>
        <File Id="RubyExeManual"
                  KeyPath="yes"
                  Source="stagedir\sys\ruby\bin\ruby.exe" />
        <ServiceInstall Id="ServiceInstallerManual"
                                  Account="[PUPPET_AGENT_ACCOUNT_DOMAIN]\[PUPPET_AGENT_ACCOUNT_USER]"
                                  Password="[PUPPET_AGENT_ACCOUNT_PASSWORD]"
                                  Description="Periodically fetches and applies configurations from a Puppet master server."
                                  DisplayName="Puppet Agent"
                                  Interactive="no"
                                  Name="$(var.PuppetServiceName)"
                                  Start="demand"
                                  Type="ownProcess"
                                  ErrorControl="normal"
                                  Vital="yes"
                                  Arguments="-rubygems &quot;[INSTALLDIR]service\daemon.rb&quot;" />
        <ServiceControl Id="ServiceControlOptionsManual"
                                  Stop="both"
                                  Remove="uninstall"
                                  Name="$(var.PuppetServiceName)"
                                  Wait="yes" />
      </Component>
      <Component Id='PuppetServiceDisabled' Guid="4D3A8CAF-C675-46AC-B3AD-75F00581D0DB" Win64="$(var.Win64)">
        <Condition>
          <![CDATA[PUPPET_AGENT_STARTUP_MODE ~= "disabled"]]>
        </Condition>
        <File Id="RubyExeDisabled" KeyPath="yes" Source="stagedir\sys\ruby\bin\ruby.exe" />
        <ServiceInstall Id="ServiceInstallerDisabled"
                                  Account="[PUPPET_AGENT_ACCOUNT_DOMAIN]\[PUPPET_AGENT_ACCOUNT_USER]"
                                  Password="[PUPPET_AGENT_ACCOUNT_PASSWORD]"
                                  Description="Periodically fetches and applies configurations from a Puppet master server."
                                  DisplayName="Puppet Agent"
                                  Interactive="no"
                                  Name="$(var.PuppetServiceName)"
                                  Start="disabled"
                                  Type="ownProcess"
                                  ErrorControl="normal"
                                  Vital="yes"
                                  Arguments="-rubygems &quot;[INSTALLDIR]service\daemon.rb&quot;" />
        <ServiceControl Id="ServiceControlOptionsDisabled"
                                    Stop="both"
                                    Remove="uninstall"
                                    Name="$(var.PuppetServiceName)"
                                    Wait="yes" />
      </Component>
      <Component Id='MCOService' Guid="7601FCEA-90B3-CC69-6A69-4087FBC7292D" Win64="$(var.Win64)">
        <File Id="RubyWExe" KeyPath="yes" Source="stagedir\sys\ruby\bin\rubyw.exe" />
        <!-- This service is installed with start set to demand because
        it won't be correctly configured to start right away. The
        puppet run that configures mcollective will allow it to start
        and set it to automatic -->
        <ServiceInstall Id="MCOServiceInstaller"
                                  Account="[PUPPET_AGENT_ACCOUNT_DOMAIN]\[PUPPET_AGENT_ACCOUNT_USER]"
                                  Password="[PUPPET_AGENT_ACCOUNT_PASSWORD]"
                                  Description="Puppet Labs server orchestration framework"
                                  DisplayName="Marionette Collective Server"
                                  Interactive="no"
                                  Name="mcollective"
                                  Start="demand"
                                  Type="ownProcess"
                                  ErrorControl="normal"
                                  Vital="yes"
                                  Arguments="-I&quot;[INSTALLDIR]puppet\lib;[INSTALLDIR]facter\lib;[INSTALLDIR]hiera\lib;[INSTALLDIR]mcollective\lib&quot; -rubygems &quot;[INSTALLDIR]mcollective\bin\mcollectived&quot; --daemonize" />
        <ServiceControl Id="MCOStartService"
                                    Stop="both"
                                    Remove="uninstall"
                                    Name="mcollective"
                                    Wait="yes" />
      </Component>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="wix:Component[wix:File[@Source='$(var.StageDir)\ruby\bin\rubyw.exe']]" />
</xsl:stylesheet>
