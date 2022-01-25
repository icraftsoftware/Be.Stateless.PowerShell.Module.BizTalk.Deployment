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

using System;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Dsl;
using Be.Stateless.BizTalk.Dsl.Binding;
using Be.Stateless.BizTalk.Dsl.Binding.Extensions;
using Be.Stateless.BizTalk.Install;
using Be.Stateless.BizTalk.Management.Automation;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "MemberCanBeProtected.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	public abstract class ApplicationBindingCmdlet : PSCmdlet
	{
		#region Base Class Member Overrides

		protected sealed override void ProcessRecord()
		{
			var resolvedApplicationBindingAssemblyFilePath = this.ResolvePath(ApplicationBindingAssemblyFilePath);
			var assemblyResolutionProbingPaths = this.ResolvePaths(AssemblyProbingFolderPath)
				.Prepend(Path.GetDirectoryName(resolvedApplicationBindingAssemblyFilePath))
				.Prepend(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location))
				.ToArray();

			using (new BizTalkAssemblyResolver(WriteVerbose, true, assemblyResolutionProbingPaths))
			{
				WriteInformation($"Resolving ApplicationBindingType in assembly '{resolvedApplicationBindingAssemblyFilePath}'...");
				var applicationBindingType = AssemblyLoader.Load(resolvedApplicationBindingAssemblyFilePath).GetApplicationBindingType(true);
				WriteInformation($"Resolved ApplicationBindingType '{applicationBindingType.AssemblyQualifiedName}' in assembly '{applicationBindingType.Assembly.Location}'.");
				if (!EnvironmentSettingOverridesTypeName.IsNullOrEmpty())
				{
					WriteInformation($"Resolving EnvironmentSettingOverridesType '{EnvironmentSettingOverridesTypeName}'...");
					DeploymentContext.EnvironmentSettingOverridesType = Type.GetType(EnvironmentSettingOverridesTypeName, true);
					WriteInformation($"Resolved EnvironmentSettingOverridesType in assembly '{DeploymentContext.EnvironmentSettingOverridesType.Assembly.Location}'.");
				}
				DeploymentContext.TargetEnvironment = TargetEnvironment;

				var applicationBinding = (IVisitable<IApplicationBindingVisitor>) Activator.CreateInstance(applicationBindingType);
				ProcessApplicationBinding(applicationBinding);
			}
		}

		#endregion

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string ApplicationBindingAssemblyFilePath { get; set; }

		[Alias("ProbingPath")]
		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPath { get; set; }

		[Alias("SettingsTypeName")]
		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string EnvironmentSettingOverridesTypeName { get; set; }

		[Alias("Environment")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }

		protected abstract void ProcessApplicationBinding(IVisitable<IApplicationBindingVisitor> applicationBinding);

		protected void WriteInformation(string message)
		{
			WriteInformation(message, null);
		}
	}
}
