#region Copyright & License

// Copyright © 2012 - 2021 François Chabot
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#endregion

using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using Be.Stateless.BizTalk.Install.Command;
using Be.Stateless.BizTalk.Install.Command.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Application
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsLifecycle.Uninstall, Nouns.ApplicationFileAdapterFolders)]
	[OutputType(typeof(void))]
	public class UninstallApplicationFileAdapterFolders : ApplicationBindingBasedCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation($"BizTalk Application {ResolvedApplicationBindingType.FullName} file adapters' folders are being uninstalled...", null);
			ApplicationBindingCommandFactory
				.CreateApplicationFileAdapterFolderTeardownCommand(ResolvedApplicationBindingType)
				.Initialize(this)
				.Execute(msg => WriteInformation(msg, null));
			WriteInformation($"BizTalk Application {ResolvedApplicationBindingType.FullName} file adapters' folders have been uninstalled.", null);
		}

		#endregion
	}
}
