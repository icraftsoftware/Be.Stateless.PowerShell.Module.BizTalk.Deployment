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
using Be.Stateless.BizTalk.Install.Command.Dispatcher;
using Be.Stateless.BizTalk.Install.Command.Proxy;
using Be.Stateless.BizTalk.Management.Automation;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsData.Convert, Nouns.ApplicationBinding)]
	[OutputType(typeof(void))]
	public class ConvertApplicationBinding : ApplicationBindingBasedCmdlet, ISetupCommandProxy<ApplicationBindingGenerationCommandProxy>
	{
		#region ISetupCommandProxy<ApplicationBindingGenerationCommandProxy> Members

		void ISetupCommandProxy<ApplicationBindingGenerationCommandProxy>.Setup(ApplicationBindingGenerationCommandProxy commandProxy)
		{
			Setup(commandProxy);
			commandProxy.OutputFilePath = this.ResolvePath(OutputFilePath);
		}

		#endregion

		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation("Generating BizTalk Application XML bindings...", null);
			using (var dispatcher = CommandDispatcherFactory<ApplicationBindingGenerationCommandProxy>.Create(this, NoLock))
			{
				dispatcher.Run();
			}
		}

		#endregion

		[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
		[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string OutputFilePath { get; set; }
	}
}
