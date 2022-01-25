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
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Dsl.Binding.Visitor
{
	/// <summary>
	/// <see cref="IApplicationBindingVisitor"/> implementation that tears down file adapters' physical paths.
	/// </summary>
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Public API.")]
	public class FileAdapterFolderUninstaller : FileAdapterFolderVisitor
	{
		public FileAdapterFolderUninstaller(bool recurse, Action<string> logAppender)
		{
			_recurse = recurse;
			_logAppender = logAppender;
		}

		#region Base Class Member Overrides

		protected override void VisitDirectory(string path)
		{
			_logAppender?.Invoke($"Deleting directory '{path}'.");
			try
			{
				Directory.Delete(path, _recurse);
				_logAppender?.Invoke($"Deleted directory '{path}'.");
			}
			catch (Exception exception) when (!exception.IsFatal())
			{
				_logAppender?.Invoke($"Could not delete directory '{path}'.\r\n${exception}");
			}
		}

		#endregion

		private readonly Action<string> _logAppender;
		private readonly bool _recurse;
	}
}
