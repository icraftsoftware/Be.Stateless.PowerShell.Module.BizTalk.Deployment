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
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Install.Command;
using Be.Stateless.BizTalk.Install.Command.Dispatcher;
using Be.Stateless.BizTalk.Install.Command.Sso;
using Be.Stateless.BizTalk.Management.Automation;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsData.Update, Nouns.AffiliateApplicationStore)]
	[OutputType(typeof(void))]
	public class UpdateAffiliateApplicationStore : PSCmdlet, ISetupDispatchedCommand<DispatchedAffiliateApplicationStoreUpdateCommand>, IProvideAssemblyResolutionProbingPaths
	{
		#region IProvideAssemblyResolutionProbingPaths Members

		string[] IProvideAssemblyResolutionProbingPaths.AssemblyResolutionProbingPaths => _assemblyResolutionProbingPaths ??= this.ResolvePaths(AssemblyProbingFolderPaths)
			.Prepend(Path.GetDirectoryName(this.ResolvePath(EnvironmentSettingsAssemblyFilePath)))
			.Prepend(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location))
			.ToArray();

		#endregion

		#region ISetupDispatchedCommand<DispatchedAffiliateApplicationStoreUpdateCommand> Members

		void ISetupDispatchedCommand<DispatchedAffiliateApplicationStoreUpdateCommand>.Setup(DispatchedAffiliateApplicationStoreUpdateCommand dispatchedCommand)
		{
			dispatchedCommand.AffiliateApplicationName = AffiliateApplicationName;
			dispatchedCommand.EnvironmentSettingOverridesTypeName = EnvironmentSettingOverridesTypeName;
			dispatchedCommand.EnvironmentSettingsAssemblyFilePath = this.ResolvePath(EnvironmentSettingsAssemblyFilePath);
			dispatchedCommand.TargetEnvironment = TargetEnvironment;
		}

		#endregion

		#region Base Class Member Overrides

		[SuppressMessage("ReSharper", "SuspiciousTypeConversion.Global")]
		protected override void ProcessRecord()
		{
			using (var dispatcher = IsolatedCommandDispatcher<DispatchedAffiliateApplicationStoreUpdateCommand>.Create(this))
			{
				dispatcher.Run();
			}
		}

		#endregion

		[Alias("Name")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string AffiliateApplicationName { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPaths { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNull]
		public string EnvironmentSettingOverridesTypeName { get; set; }

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string EnvironmentSettingsAssemblyFilePath { get; set; }

		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }

		private string[] _assemblyResolutionProbingPaths;
	}
}
