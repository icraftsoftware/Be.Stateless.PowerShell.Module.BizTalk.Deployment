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
using System.IO;
using System.Reflection;
using Be.Stateless.BizTalk.Install.Command.Dispatcher;
using Xunit;
using Xunit.Abstractions;

namespace Be.Stateless.BizTalk.Install.Command.Binding
{
	public class DispatchedApplicationBindingGenerationCommandFixture : ISetupDispatchedCommand<DispatchedApplicationBindingGenerationCommand>, IDisposable
	{
		#region Setup/Teardown

		public DispatchedApplicationBindingGenerationCommandFixture(ITestOutputHelper output)
		{
			_outputAppender = new TestOutputAppender(output);
		}

		public void Dispose()
		{
			File.Delete(_outputFilePath);
		}

		#endregion

		[Fact(Skip = "Figure a way to provide the binding assembly on disk on the build server too!")]
		public void ExecuteCoreSucceeds()
		{
			using (var dispatcher = IsolatedCommandDispatcher<DispatchedApplicationBindingGenerationCommand>.Create(_outputAppender, this, AssemblyResolutionProbingPaths))
			{
				dispatcher.Run();
			}
		}

		void ISetupDispatchedCommand<DispatchedApplicationBindingGenerationCommand>.Setup(DispatchedApplicationBindingGenerationCommand dispatchedCommand)
		{
			dispatchedCommand.ApplicationBindingAssemblyFilePath = APPLICATION_BINDING_ASSEMBLY_FILE_PATH;
			dispatchedCommand.OutputFilePath = _outputFilePath;
			dispatchedCommand.TargetEnvironment = TargetEnvironment.DEVELOPMENT;
		}

		private string[] AssemblyResolutionProbingPaths => new[] {
			Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location),
			Path.GetDirectoryName(APPLICATION_BINDING_ASSEMBLY_FILE_PATH)
		};

		private readonly IOutputAppender _outputAppender;
		private readonly string _outputFilePath = Path.GetTempFileName();

		private const string APPLICATION_BINDING_ASSEMBLY_FILE_PATH =
			@"C:\Files\Projects\be.stateless\BizTalk.Factory.Batching.Application\src\Be.Stateless.BizTalk.Factory.Batching.Binding\bin\Debug\net48\Be.Stateless.BizTalk.Factory.Batching.Binding.dll";
	}
}
