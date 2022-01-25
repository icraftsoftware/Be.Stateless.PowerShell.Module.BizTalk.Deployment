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
using System.Security.AccessControl;
using Be.Stateless.Extensions;
using Path = Be.Stateless.IO.Path;

namespace Be.Stateless.BizTalk.Dsl.Binding.Visitor
{
	/// <summary>
	/// <see cref="IApplicationBindingVisitor"/> implementation that sets up file adapters' physical paths.
	/// </summary>
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Public API.")]
	public class FileAdapterFolderInstaller : FileAdapterFolderVisitor
	{
		public FileAdapterFolderInstaller(string[] users, Action<string> logAppender)
		{
			_users = users ?? throw new ArgumentNullException(nameof(users));
			_logAppender = logAppender;
		}

		#region Base Class Member Overrides

		protected override void VisitDirectory(string path)
		{
			_logAppender?.Invoke($"Setting up directory '{path}'.");
			CreateDirectory(path);
			SecureDirectory(path);
		}

		#endregion

		private void CreateDirectory(string path)
		{
			if (Directory.Exists(path))
			{
				_logAppender?.Invoke($"Directory '{path}' already exists.");
				return;
			}

			try
			{
				Directory.CreateDirectory(path);
				_logAppender?.Invoke($"Created directory '{path}'.");
			}
			catch (Exception exception) when (!exception.IsFatal())
			{
				_logAppender?.Invoke($"Could not create directory '{path}'.\r\n{exception}");
			}
		}

		private void SecureDirectory(string path)
		{
			if (!Directory.Exists(path))
			{
				_logAppender?.Invoke($"Cannot grant permissions because directory '{path}' does not exist.");
				return;
			}

			if (Path.IsNetworkPath(path))
			{
				_logAppender?.Invoke($"Cannot grant permissions because directory '{path}' is a network path.");
				return;
			}

			foreach (var user in _users)
			{
				try
				{
					var acl = Directory.GetAccessControl(path);
					acl.AddAccessRule(
						new(
							user,
							FileSystemRights.FullControl,
							InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
							PropagationFlags.None,
							AccessControlType.Allow));
					Directory.SetAccessControl(path, acl);
					_logAppender?.Invoke($"Granted Full Control permission to '{user}' on directory '{path}'.");
				}
				catch (Exception exception) when (!exception.IsFatal())
				{
					_logAppender?.Invoke($"Could not grant Full Control permission to '{user}' on directory '{path}'.\r\n{exception}");
				}
			}
		}

		private readonly Action<string> _logAppender;
		private readonly string[] _users;
	}
}
