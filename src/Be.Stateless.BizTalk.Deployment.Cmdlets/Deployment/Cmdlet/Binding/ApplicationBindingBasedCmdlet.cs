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

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "MemberCanBeProtected.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	public abstract class ApplicationBindingBasedCmdlet : PSCmdlet
	{
		//string[] IProvideAssemblyResolutionProbingPaths.AssemblyResolutionProbingPaths => _assemblyResolutionProbingPaths ??= this.ResolvePaths(AssemblyProbingFolderPaths)
		//	.Prepend(Path.GetDirectoryName(this.ResolvePath(ApplicationBindingAssemblyFilePath)))
		//	.Prepend(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location))
		//	.ToArray();

		// TODO void ISetupCommandProxy<ApplicationBindingBasedCommandProxy>.Setup(ApplicationBindingBasedCommandProxy commandProxy)
		//{
		//	commandProxy.ApplicationBindingAssemblyFilePath = this.ResolvePath(ApplicationBindingAssemblyFilePath);
		//	commandProxy.EnvironmentSettingOverridesTypeName = EnvironmentSettingOverridesTypeName;
		//	commandProxy.ExcelSettingOverridesFolderPath = this.ResolvePath(ExcelSettingOverridesFolderPath);
		//	commandProxy.TargetEnvironment = TargetEnvironment;
		//}

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string ApplicationBindingAssemblyFilePath { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPaths { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNull]
		public string EnvironmentSettingOverridesTypeName { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string ExcelSettingOverridesFolderPath { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public SwitchParameter NoLock { get; set; }

		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		// TODO [ValidateSet()]
		public string TargetEnvironment { get; set; }

		//internal void Setup(ApplicationBindingBasedCommandProxy commandProxy)
		//{
		//	((ISetupCommandProxy<ApplicationBindingBasedCommandProxy>) this).Setup(commandProxy);
		//}

		//private string[] _assemblyResolutionProbingPaths;

		protected void WriteInformation(string message)
		{
			WriteInformation(message, null);
		}
	}
}
