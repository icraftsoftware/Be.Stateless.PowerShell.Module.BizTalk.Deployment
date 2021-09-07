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
using Be.Stateless.BizTalk.Install.Command.Binding;

namespace Be.Stateless.BizTalk.Install.Command.Application
{
	[SuppressMessage("ReSharper", "ClassNeverInstantiated.Global", Justification = "Instantiated by IsolatedCommandDispatcher.")]
	internal class DispatchedApplicationFileAdapterFolderSetupCommand : DispatchedApplicationBindingBasedCommand, ISupplyApplicationFileAdapterFolderSetupCommandArguments
	{
		#region ISupplyApplicationFileAdapterFolderSetupCommandArguments Members

		public string[] Users { get; set; }

		#endregion

		#region Base Class Member Overrides

		protected override void Execute(IOutputAppender outputAppender)
		{
			outputAppender.WriteInformation($"BizTalk Application {ApplicationBindingType.FullName} file adapters' folders are being installed...");
			CommandFactory
				.CreateApplicationFileAdapterFolderSetupCommand(ApplicationBindingType)
				.InitializeParameters(this)
				.Execute(outputAppender.WriteInformation);
			outputAppender.WriteInformation($"BizTalk Application {ApplicationBindingType.FullName} file adapters' folders have been installed.");
		}

		#endregion
	}
}
