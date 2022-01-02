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
using Be.Stateless.BizTalk.Dsl.Binding.Xml.Serialization.Extensions;
using Be.Stateless.BizTalk.Install;
using Be.Stateless.BizTalk.Management.Automation;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsData.Convert, Nouns.ApplicationBinding)]
	[OutputType(typeof(void))]
	public class ConvertApplicationBinding : ApplicationBindingBasedCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation("Converting Code-First BizTalk Application Bindings to XML...", null);

			var resolvedApplicationBindingAssemblyFilePath = this.ResolvePath(ApplicationBindingAssemblyFilePath);
			var assemblyResolutionProbingPaths = this.ResolvePaths(AssemblyProbingFolderPaths)
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
				if (!ExcelSettingOverridesFolderPath.IsNullOrEmpty()) DeploymentContext.ExcelSettingOverridesFolderPath = this.ResolvePath(ExcelSettingOverridesFolderPath);
				DeploymentContext.TargetEnvironment = TargetEnvironment;

				var applicationBinding = (IVisitable<IApplicationBindingVisitor>) Activator.CreateInstance(applicationBindingType);
				applicationBinding.GetApplicationBindingInfoSerializer().Save(this.ResolvePath(OutputFilePath));
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
