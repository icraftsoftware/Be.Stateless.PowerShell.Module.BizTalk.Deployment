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
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Reflection;
using System.Text;
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

		[SuppressMessage("ReSharper", "PossibleMultipleEnumeration")]
		protected override void ProcessRecord()
		{
			var applicationBindingAssemblyFilePath = this.ResolvePath(ApplicationBindingAssemblyFilePath);
			var assemblyProbingFolderPaths = this.ResolvePaths(AssemblyProbingFolderPaths);
			var excelSettingOverridesFolderPath = this.ResolvePath(ExcelSettingOverridesFolderPath);
			var outputFilePath = this.ResolvePath(OutputFilePath);

			if (NoLock)
			{
				WriteInformation("Dispatching Code-First BizTalk Application Bindings Conversion to XML in Isolated Process...");
				var tmpOutputFilePath = Path.GetTempFileName();
				var builder = new StringBuilder();
				builder.AppendLine("& {");
				builder.AppendLine($"  Import-Module -Name '{Assembly.GetExecutingAssembly().Location}'");
				builder.AppendLine("  $arguments = @{");
				builder.AppendLine($"    ApplicationBindingAssemblyFilePath = '{applicationBindingAssemblyFilePath}'");
				if (assemblyProbingFolderPaths.Any()) builder.AppendLine($"    AssemblyProbingFolderPaths = @('{string.Join("','", assemblyProbingFolderPaths)}')");
				if (!EnvironmentSettingOverridesTypeName.IsNullOrEmpty()) builder.AppendLine($"    EnvironmentSettingOverridesTypeName = '{EnvironmentSettingOverridesTypeName}'");
				if (!excelSettingOverridesFolderPath.IsNullOrEmpty()) builder.AppendLine($"    ExcelSettingOverridesFolderPath = '{excelSettingOverridesFolderPath}'");
				builder.AppendLine($"    OutputFilePath = '{tmpOutputFilePath}'");
				builder.AppendLine($"    TargetEnvironment = '{TargetEnvironment}'");
				var boundParameters = MyInvocation.BoundParameters;
				//if (boundParameters.TryGetValue("InformationAction", out var ia)) builder.AppendLine($"    InformationAction = '{ia}'");
				if (boundParameters.TryGetValue("Verbose", out var v) && v is SwitchParameter flag && flag.ToBool()) builder.AppendLine("    Verbose = $true");
				builder.AppendLine("  }");
				builder.AppendLine("  Convert-ApplicationBinding @arguments -InformationAction Continue");
				if (!NoExit) builder.AppendLine("  if ($?) { Exit 0 }");
				builder.Append('}');
				var command = builder.ToString();
				WriteDebug(command);

				var startInfo = new ProcessStartInfo {
					Arguments = (NoExit ? "-NoExit " : "") + $"-NoLogo -NoProfile -EncodedCommand {Convert.ToBase64String(Encoding.Unicode.GetBytes(command))}",
					FileName = "PowerShell.exe",
					WorkingDirectory = Path.GetDirectoryName(applicationBindingAssemblyFilePath)!
				};
				Process.Start(startInfo)!.WaitForExit();
				var fileInfo = new FileInfo(tmpOutputFilePath);
				if (!fileInfo.Exists || fileInfo.Length < 1)
					throw new InvalidOperationException("Code-First BizTalk Application Bindings Conversion to XML failed in Isolated Process.");
				File.Delete(outputFilePath);
				File.Move(tmpOutputFilePath, outputFilePath);
			}
			else
			{
				WriteInformation("Converting Code-First BizTalk Application Bindings to XML...");
				ProcessRecord(
					applicationBindingAssemblyFilePath,
					assemblyProbingFolderPaths,
					EnvironmentSettingOverridesTypeName,
					excelSettingOverridesFolderPath,
					outputFilePath,
					TargetEnvironment);
			}
		}

		#endregion

		[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
		[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string OutputFilePath { get; set; }

		private void ProcessRecord(
			string applicationBindingAssemblyFilePath,
			IEnumerable<string> assemblyProbingFolderPaths,
			string environmentSettingOverridesTypeName,
			string excelSettingOverridesFolderPath,
			string outputFilePath,
			string targetEnvironment)
		{
			var probingFolderPaths = assemblyProbingFolderPaths
				.Prepend(Path.GetDirectoryName(applicationBindingAssemblyFilePath))
				// TODO ?? .Prepend(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location))
				.ToArray();

			using (new BizTalkAssemblyResolver(WriteVerbose, true, probingFolderPaths))
			{
				WriteInformation($"Resolving ApplicationBindingType in assembly '{applicationBindingAssemblyFilePath}'...");
				var applicationBindingType = AssemblyLoader.Load(applicationBindingAssemblyFilePath).GetApplicationBindingType(true);
				WriteInformation($"Resolved ApplicationBindingType '{applicationBindingType.AssemblyQualifiedName}' in assembly '{applicationBindingType.Assembly.Location}'.");
				if (!environmentSettingOverridesTypeName.IsNullOrEmpty())
				{
					WriteInformation($"Resolving EnvironmentSettingOverridesType '{EnvironmentSettingOverridesTypeName}'...");
					DeploymentContext.EnvironmentSettingOverridesType = Type.GetType(environmentSettingOverridesTypeName, true);
					WriteInformation($"Resolved EnvironmentSettingOverridesType in assembly '{DeploymentContext.EnvironmentSettingOverridesType.Assembly.Location}'.");
				}
				if (!excelSettingOverridesFolderPath.IsNullOrEmpty()) DeploymentContext.ExcelSettingOverridesFolderPath = excelSettingOverridesFolderPath;
				DeploymentContext.TargetEnvironment = targetEnvironment;

				var applicationBinding = (IVisitable<IApplicationBindingVisitor>) Activator.CreateInstance(applicationBindingType);
				applicationBinding.GetApplicationBindingInfoSerializer().Save(outputFilePath);
			}
		}
	}
}
