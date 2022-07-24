# BizTalk.Deployment PowerShell Module

##### Build Pipelines

[![][pipeline.mr.badge]][pipeline.mr]

[![][pipeline.ci.badge]][pipeline.ci]

##### Latest Release

[![][module.badge]][module]

[![][release.badge]][release]

##### Release Preview

[![][module.preview.badge]][module.preview]

##### Documentation

[![][doc.main.badge]][doc.main]

[![][doc.this.badge]][doc.this]

## Overview

`BizTalk.Deployment` is an extensible `PowerShell` utility module based on a deployment framework featuring a declarative resource-driven task model and providing commands to deploy full-fledged Microsoft BizTalk Server® applications.

This module furthermore depends on the following third-party `PowerShell` Modules:

- [Gac](https://www.powershellgallery.com/packages/Gac);
- [InvokeBuild][invoke-build];
- [SqlServer](https://www.powershellgallery.com/packages/SqlServer).

## Installation

In order to be able to install the `PowerShell` module, you might have to trust the `be.stateless`'s certificate public key beforehand; see these [instructions][doc.install] for details on how to proceed.

<!-- badges -->

[doc.install]: https://www.stateless.be/PowerShell/Module/Installation.html "PowerShell Module Installation"
[doc.main.badge]: https://img.shields.io/static/v1?label=BizTalk.Factory%20SDK&message=User's%20Guide&color=8CA1AF&logo=readthedocs
[doc.main]: https://www.stateless.be/ "BizTalk.Factory SDK User's Guide"
[doc.this.badge]: https://img.shields.io/static/v1?label=BizTalk.Deployment&message=User's%20Guide&color=8CA1AF&logo=readthedocs
[doc.this]: https://www.stateless.be/PowerShell/Module/BizTalk/Deployment "BizTalk.Deployment PowerShell Module User's Guide"
[github.badge]: https://img.shields.io/static/v1?label=Repository&message=Be.Stateless.PowerShell.Module.BizTalk.Deployment&logo=github
[github]: https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment "Be.Stateless.PowerShell.Module.BizTalk.Deployment GitHub Repository"
[module.badge]: https://img.shields.io/powershellgallery/v/BizTalk.Deployment.svg?label=BizTalk.Deployment&style=flat&logo=powershell
[module]: https://www.powershellgallery.com/packages/BizTalk.Deployment "BizTalk.Deployment Module"
[module.preview.badge]: https://badge-factory.azurewebsites.net/package/icraftsoftware/be.stateless/BizTalk.Factory.Preview/BizTalk.Deployment?logo=powershell
[module.preview]: https://dev.azure.com/icraftsoftware/be.stateless/_packaging?_a=package&feed=BizTalk.Factory.Preview&package=BizTalk.Deployment&protocolType=NuGet "BizTalk.Deployment PowerShell Module Preview"
[pipeline.ci.badge]: https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.BizTalk.Deployment%20Continuous%20Integration?branchName=master&label=Continuous%20Integration%20Build
[pipeline.ci]: https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=29&branchName=master "Be.Stateless.PowerShell.Module.BizTalk.Deployment Continuous Integration Build Pipeline"
[pipeline.mr.badge]: https://dev.azure.com/icraftsoftware/be.stateless/_apis/build/status/Be.Stateless.PowerShell.Module.BizTalk.Deployment%20Manual%20Release?branchName=master&label=Manual%20Release%20Build
[pipeline.mr]: https://dev.azure.com/icraftsoftware/be.stateless/_build/latest?definitionId=30&branchName=master "Be.Stateless.PowerShell.Module.BizTalk.Deployment Manual Release Build Pipeline"
[release.badge]: https://img.shields.io/github/v/release/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment?label=Release&logo=github
[release]: https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/releases/latest "Be.Stateless.PowerShell.Module.BizTalk.Deployment Release"

<!-- links -->

[invoke-build]: https://github.com/nightroman/Invoke-Build
