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

using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Xsl;
using Be.Stateless.Extensions;
using Be.Stateless.Resources;
using Be.Stateless.Xml.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Binding
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsData.Expand, Nouns.ApplicationBinding)]
	[OutputType(typeof(void))]
	public class ExpandApplicationBinding : ProviderPathResolvingCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation($"BizTalk Application bindings '{ResolvedInputPath}' are being expanded...", null);
			var xmlBindings = new XmlDocument();
			xmlBindings.Load(ResolvedInputPath);
			UnescapeXmlBindingTree(xmlBindings.DocumentElement);
			if (Trimmed.IsPresent && Trimmed) TrimXmlBindingTree(xmlBindings);
			xmlBindings.Save(ResolvedOutputFilePath);
			WriteInformation($"BizTalk Application bindings '{ResolvedInputPath}' have been expanded.", null);
		}

		#endregion

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string InputFilePath { get; set; }

		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string OutputFilePath { get; set; }

		[Parameter(Mandatory = false)]
		public SwitchParameter Trimmed { get; set; }

		private string ResolvedInputPath => _resolvedInputFilePath ??= ResolvePowerShellPath(InputFilePath, nameof(InputFilePath));

		[SuppressMessage("ReSharper", "InvertIf")]
		private string ResolvedOutputFilePath
		{
			get
			{
				if (_resolvedOutputFilePath == null)
				{
					_resolvedOutputFilePath = OutputFilePath.IsNullOrEmpty()
						? Path.Combine(Path.GetDirectoryName(ResolvedInputPath)!, Path.GetFileNameWithoutExtension(ResolvedInputPath) + ".unescaped.xml")
						: SessionState.Path.GetUnresolvedProviderPathFromPSPath(OutputFilePath);
					WriteDebug($"Resolved {nameof(OutputFilePath)}: '{_resolvedOutputFilePath}'.");
				}
				return _resolvedOutputFilePath;
			}
		}

		private void TrimXmlBindingTree(XmlDocument xmlDocument)
		{
			var xslCompiledTransform = ResourceManager.Load(
				Assembly.GetExecutingAssembly(),
				GetType().FullName + ".Trimmer.xslt",
				stream => {
					using (var xmlReader = XmlReader.Create(stream))
					{
						var xslt = new XslCompiledTransform(true);
						xslt.Load(xmlReader, XsltSettings.TrustedXslt, new XmlUrlResolver());
						return xslt;
					}
				});
			using (var xmlReader = XmlReader.Create(xmlDocument.AsStream()))
			using (var writer = new StringWriter())
			using (var xmlWriter = XmlWriter.Create(writer, new XmlWriterSettings { OmitXmlDeclaration = true }))
			{
				xslCompiledTransform.Transform(xmlReader, xmlWriter);
				writer.Flush();
				xmlDocument.LoadXml(writer.ToString());
			}
		}

		private void UnescapeXmlBindingTree(XmlNode node)
		{
			// to be unescaped, a text node must be a node's only child
			if (node.ChildNodes.Count == 1 && node.ChildNodes[0].NodeType == XmlNodeType.Text)
			{
				// as text node cannot have any child, this ongoing recursive iteration step can be ended if it does not need to be
				// unescaped --- this is a small optimization that is not required and merely avoids the following foreach loop
				if (!node.InnerXml.Contains("&lt;")) return;
				const string xmlProcessingInstructionPattern = @"<\?xml .+\?>\s*";
				node.InnerXml = Regex.Replace(node.InnerText, xmlProcessingInstructionPattern, string.Empty);
			}
			// also try to unescape current node's newly created XML subtree if it was a text node that has just been unescaped
			foreach (XmlNode childNode in node.ChildNodes)
			{
				UnescapeXmlBindingTree(childNode);
			}
		}

		private string _resolvedInputFilePath;
		private string _resolvedOutputFilePath;
	}
}
