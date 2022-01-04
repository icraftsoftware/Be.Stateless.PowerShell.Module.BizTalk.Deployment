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

using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using System.Management.Automation.Language;
using static Be.Stateless.BizTalk.Install.TargetEnvironment;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "MemberCanBeProtected.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	public abstract class ApplicationBindingBasedCmdlet : PSCmdlet
	{
		#region Nested Type: EnvironmentCompleter

		internal class EnvironmentCompleter : IArgumentCompleter
		{
			#region IArgumentCompleter Members

			public IEnumerable<CompletionResult> CompleteArgument(
				string commandName,
				string parameterName,
				string wordToComplete,
				CommandAst commandAst,
				IDictionary fakeBoundParameters)
			{
				return new[] {
					new CompletionResult(DEVELOPMENT),
					new CompletionResult(BUILD),
					new CompletionResult(INTEGRATION),
					new CompletionResult(ACCEPTANCE),
					new CompletionResult(PREPRODUCTION),
					new CompletionResult(PRODUCTION)
				};
			}

			#endregion
		}

		#endregion

		[Alias("Path")]
		[Parameter(Mandatory = true, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = true, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string ApplicationBindingAssemblyFilePath { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = false, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string[] AssemblyProbingFolderPaths { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = false, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNull]
		public string EnvironmentSettingOverridesTypeName { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = false, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string ExcelSettingOverridesFolderPath { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public SwitchParameter NoExit { get; set; }

		[Parameter(Mandatory = false, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = true, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public SwitchParameter NoLock { get; set; }

		[Parameter(Mandatory = true, ParameterSetName = SAME_PROCESS_PARAMETER_SET_NAME)]
		[Parameter(Mandatory = true, ParameterSetName = OTHER_PROCESS_PARAMETER_SET_NAME)]
		[ArgumentCompleter(typeof(EnvironmentCompleter))]
		[ValidateNotNullOrEmpty]
		public string TargetEnvironment { get; set; }

		protected void WriteInformation(string message)
		{
			WriteInformation(message, null);
		}

		protected const string OTHER_PROCESS_PARAMETER_SET_NAME = "other-process";
		protected const string SAME_PROCESS_PARAMETER_SET_NAME = "same-process";
	}
}
