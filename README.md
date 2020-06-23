# Be.Stateless.PowerShell.Module.BizTalk.Deployment

[![Build Status](https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.BizTalk.Deployment%20Manual%20Release?branchName=master)](https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=30&branchName=master)
[![GitHub Release](https://img.shields.io/github/v/release/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment)](https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/releases/latest)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/BizTalk.Deployment.svg?style=flat)](https://www.powershellgallery.com/packages/BizTalk.Deployment/)

Commands to deploy Microsoft BizTalk Server Applications supported by a deployment framework featuring a declarative task model.

## Module Installation

Notice that to be able to install this PowerShell module right from the PowerShell Gallery you will need to trust the certificate that was used to sign it. Run the following PowerShell commands (they merely download and install the certificate's public key in the 'Trusted People' store underneath the 'Local Machine' certifcate store):
```PowerShell
$filepath = "$($env:TEMP)\be.stateless.cer"
Invoke-WebRequest https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/raw/master/be.stateless.cer -OutFile $filepath
Import-Certificate -FilePath $filepath -CertStoreLocation Cert:\LocalMachine\TrustedPeople\
Remove-Item $filepath
```
