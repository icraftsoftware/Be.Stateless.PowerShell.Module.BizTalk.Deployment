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

namespace Be.Stateless.BizTalk.Install.Command.Dispatcher
{
	internal class CommandDispatcher<T> : IDisposable
		where T : MarshalByRefObject, IDispatchedCommand, new()
	{
		internal CommandDispatcher(IOutputAppender outputAppender, ISetupDispatchedCommand<T> dispatchedCommandSetupper, string[] assemblyResolutionProbingPaths)
			: this(outputAppender, assemblyResolutionProbingPaths)
		{
			if (dispatchedCommandSetupper == null) throw new ArgumentNullException(nameof(dispatchedCommandSetupper));
			DispatchedCommand = new();
			dispatchedCommandSetupper.Setup(DispatchedCommand);
		}

		protected CommandDispatcher(IOutputAppender outputAppender, string[] assemblyResolutionProbingPaths)
		{
			_assemblyResolutionProbingPaths = assemblyResolutionProbingPaths;
			_outputAppender = outputAppender ?? throw new ArgumentNullException(nameof(outputAppender));
		}

		#region IDisposable Members

		public void Dispose()
		{
			Dispose(true);
			GC.SuppressFinalize(this);
		}

		#endregion

		protected T DispatchedCommand { get; set; }

		public void Run()
		{
			DispatchedCommand.Execute(_outputAppender, _assemblyResolutionProbingPaths);
		}

		protected virtual void Dispose(bool disposing) { }

		private readonly string[] _assemblyResolutionProbingPaths;
		private readonly IOutputAppender _outputAppender;
	}
}
