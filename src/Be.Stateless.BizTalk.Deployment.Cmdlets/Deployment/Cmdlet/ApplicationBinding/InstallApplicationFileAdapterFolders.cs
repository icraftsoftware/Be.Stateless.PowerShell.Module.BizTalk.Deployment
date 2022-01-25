#region Copyright & License

// Copyright © 2012 - 2022 François Chabot
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
using Be.Stateless.BizTalk.Dsl;
using Be.Stateless.BizTalk.Dsl.Binding;
using Be.Stateless.BizTalk.Dsl.Binding.Visitor;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsLifecycle.Install, Nouns.ApplicationFileAdapterFolders)]
	[OutputType(typeof(void))]
	public class InstallApplicationFileAdapterFolders : ApplicationBindingCmdlet
	{
		#region Base Class Member Overrides

		protected override void BeginProcessing()
		{
			WriteInformation("Creating Folders for File Adapters Defined by Code-First BizTalk Application Bindings...");
		}

		#endregion

		#region Base Class Member Overrides

		protected override void ProcessApplicationBinding(IVisitable<IApplicationBindingVisitor> applicationBinding)
		{
			applicationBinding.Accept(new FileAdapterFolderInstaller(User, WriteInformation));
		}

		#endregion

		[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
		[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string[] User { get; set; }
	}
}
