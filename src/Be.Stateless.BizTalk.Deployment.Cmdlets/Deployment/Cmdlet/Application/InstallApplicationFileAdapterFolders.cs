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
using Be.Stateless.BizTalk.Deployment.Cmdlet.Binding;
using Be.Stateless.BizTalk.Install.Command;
using Be.Stateless.BizTalk.Install.Command.Application;
using Be.Stateless.BizTalk.Install.Command.Dispatcher;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Application
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsLifecycle.Install, Nouns.ApplicationFileAdapterFolders)]
	[OutputType(typeof(void))]
	public class InstallApplicationFileAdapterFolders : ApplicationBindingBasedCmdlet, ISetupDispatchedCommand<DispatchedApplicationFileAdapterFolderSetupCommand>
	{
		#region ISetupDispatchedCommand<DispatchedApplicationFileAdapterFolderSetupCommand> Members

		void ISetupDispatchedCommand<DispatchedApplicationFileAdapterFolderSetupCommand>.Setup(DispatchedApplicationFileAdapterFolderSetupCommand dispatchedCommand)
		{
			Setup(dispatchedCommand);
			dispatchedCommand.Users = Users;
		}

		#endregion

		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			using (var dispatcher = CommandDispatcherFactory<DispatchedApplicationFileAdapterFolderSetupCommand>.Create(this))
			{
				dispatcher.Run();
			}
		}

		#endregion

		[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
		[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string[] Users { get; set; }
	}
}
