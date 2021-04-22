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

using System;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Dsl.Binding.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "MemberCanBeProtected.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	public abstract class ApplicationBindingBasedCmdlet : ProviderPathResolvingCmdlet
	{
		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string ApplicationBindingAssemblyFilePath { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPaths { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNull]
		public Type EnvironmentSettingOverridesType { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string ExcelSettingOverridesFolderPath { get; set; }

		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }

		protected internal string ResolvedApplicationBindingAssemblyFilePath =>
			_resolvedApplicationBindingAssemblyFilePath ??= ResolvePowerShellPath(ApplicationBindingAssemblyFilePath, nameof(ApplicationBindingAssemblyFilePath));

		[SuppressMessage("ReSharper", "InvertIf")]
		protected internal Type ResolvedApplicationBindingType
		{
			get
			{
				if (_resolvedApplicationBindingType == null)
				{
					// see https://stackoverflow.com/a/1477899/1789441
					// see https://stackoverflow.com/a/41858160/1789441
					_resolvedApplicationBindingType = AppDomain
						.CurrentDomain
						.Load(Assembly.LoadFile(ResolvedApplicationBindingAssemblyFilePath).GetName())
						.GetApplicationBindingType(true);
					WriteDebug($"Resolved ApplicationBindingType: '{_resolvedApplicationBindingType.AssemblyQualifiedName}'.");
				}
				return _resolvedApplicationBindingType;
			}
		}

		protected internal string[] ResolvedAssemblyProbingFolderPaths =>
			_resolvedAssemblyProbingFolderPaths ??= ResolvePowerShellPaths(AssemblyProbingFolderPaths, nameof(AssemblyProbingFolderPaths));

		protected internal string ResolvedExcelSettingOverridesFolderPath =>
			_resolvedExcelSettingOverridesFolderPath ??= ResolvePowerShellPath(ExcelSettingOverridesFolderPath, nameof(ExcelSettingOverridesFolderPath));

		private string _resolvedApplicationBindingAssemblyFilePath;
		private Type _resolvedApplicationBindingType;
		private string[] _resolvedAssemblyProbingFolderPaths;
		private string _resolvedExcelSettingOverridesFolderPath;
	}
}
