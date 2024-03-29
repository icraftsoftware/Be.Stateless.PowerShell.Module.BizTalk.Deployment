﻿#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

<#
.SYNOPSIS
   Converts Code-First Microsoft BizTalk Server Application Bindings to XML.
.DESCRIPTION
   Loads an .NET assembly containing the BizTalk Application Bindings written in BizTalk.Factory's C#-embedded Domain Specific Languages (DSL) and converts them to XML.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER OutputFilePath
   Path of the generated file that will contain the XML BizTalk Application Bindings.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Batching.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV

   Silently converts the .NET application binding assembly to XML.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV -InformationAction Continue -Verbose

   Converts the .NET application binding assembly to XML and provides detailed information during the process.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV -Isolated -InformationAction Continue -Verbose

   Converts the .NET application binding assembly to XML in a separate process and provides detailed information during the process.
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Convert-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Destination')]
      [Parameter(Position = 1, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $OutputFilePath,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Conversion of Code-First BizTalk Application Bindings to XML to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Convert-CoreApplicationBinding @using:arguments
      }
   } else {
      Convert-CoreApplicationBinding @arguments
   }
}

<#
.SYNOPSIS
   Expands XML encoded nodes in the XML application binding generated by the Convert-ApplicationBinding command.
.DESCRIPTION
   Microsoft BizTalk XML application bindings contain a bunch of XML-encoded nodes, such as adapter configurations, that make them hard to read. This command decodes
   these XML-encoded nodes in plain XML. Notice that they are no reverse command to encode back the XML bindings that one would have edited.
.PARAMETER InputFilePath
   Path to the XML application binding file generated via the Convert-ApplicationBinding command.
.PARAMETER OutputFilePath
   Optional path to the file to which to write the XML application binding expansion result to. It defaults to "<InputFilePath>.expanded.xml".
.PARAMETER Trim
   Whether to clean up the expanded bindings, e.g. discard empty stages, empty default values, enclosed passwords/pass phrases in CDATA, etc. and clear empty
   pipelines, i.e. pipelines without any component at any stage.
.EXAMPLE
   PS> Expand-ApplicationBinding InputFilePath Bindings.xml -Trim
.EXAMPLE
   PS> Expand-ApplicationBinding InputFilePath Bindings.xml -OutputFilePath Bindings.decoded.xml
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Expand-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $InputFilePath,

      [Alias('Destination')]
      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $OutputFilePath,

      [Parameter(Mandatory = $false)]
      [switch]
      $Trim
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   Expand-CoreApplicationBinding @PSBoundParameters
}

<#
.SYNOPSIS
   Gets the names of the host instances configured by the Code-First Microsoft BizTalk Server Application Bindings.
.DESCRIPTION
   Gets the names of the host instances configured by the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Get-ApplicationHosts -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Batching.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Get-ApplicationHosts -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Get-ApplicationHosts -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Get-ApplicationHosts {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Enumeration of BizTalk Hosts Bound by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Get-CoreApplicationHosts @using:arguments
      }
   } else {
      Get-CoreApplicationHosts @arguments
   }
}

<#
.SYNOPSIS
   Initializes the services of a Microsoft BizTalk Application as configured by the Code-First Microsoft BizTalk Server Application Bindings.
.DESCRIPTION
   Initializes the services of a Microsoft BizTalk Application in accordance to their expected state as configured by the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER InitializationOption
   The set of Microsoft BizTalk Server® services, or artifacts, to start after deployment is complete. This is bitmask enumeration defining the following values:
   - None, when no services at all have to be started,
   - Orchestrations, when only the orchestrations have to be started,
   - ReceiveLocations, when only the receive locations have to be enabled,
   - SendPorts, when only the send ports have to be started,
   - All, when all of the above services have to started. It is the default value and is equivalent to passing the following array of values: Orchestrations,
     ReceiveLocations, SendPorts.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Initialize-ApplicationState -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Batching.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Initialize-ApplicationState -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -InitializationOption Orchestrations, SendPorts
.EXAMPLE
   PS> Initialize-ApplicationState -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -Isolated
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Initialize-ApplicationState {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Alias('Options')]
      [Parameter(Mandatory = $false)]
      [Be.Stateless.BizTalk.Dsl.Binding.Visitor.BizTalkServiceInitializationOptions]
      $InitializationOption = @('All'),

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Initialization of BizTalk Services'' State to that Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Initialize-CoreApplicationState @using:arguments
      }
   } else {
      Initialize-CoreApplicationState @arguments
   }
}

<#
.SYNOPSIS
   Creates the folders declared by both inbound and outbound file adapters configured by the Code-First Microsoft BizTalk Server Application Bindings.
.DESCRIPTION
   Creates the folders declared by both inbound and outbound file adapters configured by the Code-First Microsoft BizTalk Server Application Bindings, and modifies
   their ACLs to grant full control to the users passed by the User parameter.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.PARAMETER User
   The names of the users or groups, local or not, to be granted full access control over the folders declared by both inbound and outbound Microsoft BizTalk
   Server file adapters.
.EXAMPLE
   PS> Install-ApplicationFileAdapterFolders -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -User "$($env:COMPUTERNAME)\BizTalk Application Users", 'BUILTIN\Users'
.EXAMPLE
   PS> Install-ApplicationFileAdapterFolders -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -User "$($env:COMPUTERNAME)\BizTalk Application Users", 'BUILTIN\Users' -Isolated
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Install-ApplicationFileAdapterFolders {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $User
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Creation of Folders for File Adapters Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Install-CoreApplicationFileAdapterFolders @using:arguments
      }
   } else {
      Install-CoreApplicationFileAdapterFolders @arguments
   }
}

<#
.SYNOPSIS
   Validates that the Code-First Microsoft BizTalk Server Application Bindings can be successfully generated for a given target environment.
.DESCRIPTION
   Validates that the Code-First Microsoft BizTalk Server Application Bindings can be successfully generated for a given target environment.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Test-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Test-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -Isolated
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Test-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Code-First BizTalk Application Bindings Validity Test to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Test-CoreApplicationBinding @using:arguments
      }
   } else {
      Test-CoreApplicationBinding @arguments
   }
}

<#
.SYNOPSIS
   Validates that the services of a Microsoft BizTalk Application as configured by the Code-First Microsoft BizTalk Server Application Bindings are in their expected
   configured state.
.DESCRIPTION
   Validates that the services of a Microsoft BizTalk Application as configured by the Code-First Microsoft BizTalk Server Application Bindings are in their expected
   configured state.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Test-ApplicationState -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Test-ApplicationState -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -Isolated
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Test-ApplicationState {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Correspondence Test of BizTalk Services'' State to that Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Test-CoreApplicationState @using:arguments
      }
   } else {
      Test-CoreApplicationState @arguments
   }
}

<#
.SYNOPSIS
   Deletes the folders declared by both inbound and outbound file adapters configured by the Code-First Microsoft BizTalk Server Application Bindings.
.DESCRIPTION
   Deletes the folders declared by both inbound and outbound file adapters configured by the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First Microsoft BizTalk Server Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process so as not to lock it.
.PARAMETER Recurse
   Whether to recursively delete the folders that have been created for file adapters.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.EXAMPLE
   PS> Uninstall-ApplicationFileAdapterFolders -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV
.EXAMPLE
   PS> Uninstall-ApplicationFileAdapterFolders -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -TargetEnvironment DEV -Isolated
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/ApplicationBindingCommands.html
.NOTES
   © 2022 be.stateless.
#>
function Uninstall-ApplicationFileAdapterFolders {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Parameter(Mandatory = $false)]
      [switch]
      $Recurse,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Deletion of Folders for File Adapters Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Uninstall-CoreApplicationFileAdapterFolders @using:arguments
      }
   } else {
      Uninstall-CoreApplicationFileAdapterFolders @arguments
   }
}

<#
 # Argument Completers
 #>

Register-ArgumentCompleter -ParameterName TargetEnvironment -ScriptBlock {
   param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   @('DEV', 'BLD', 'INT', 'ACC', 'PRE', 'PRD') | Where-Object -FilterScript { $_ -like "$wordToComplete*" }
}
