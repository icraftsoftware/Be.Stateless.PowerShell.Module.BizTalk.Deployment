﻿#region Copyright & License

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

using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Xsl;
using Be.Stateless.BizTalk.Management.Automation;
using Be.Stateless.Extensions;
using Be.Stateless.Resources;
using Be.Stateless.Xml.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "ClassWithVirtualMembersNeverInherited.Global", Justification = "Used by Moq.")]
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	[Cmdlet(VerbsData.Expand, Nouns.ApplicationBinding)]
	[OutputType(typeof(void))]
	public class ExpandApplicationBinding : PSCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			WriteInformation($"Expanding XML BizTalk Application Bindings '{ResolvedInputPath}'...", null);
			var xmlBindings = new XmlDocument();
			xmlBindings.Load(ResolvedInputPath);
			UnescapeXmlTree(xmlBindings.DocumentElement);
			if (Trim.IsPresent && Trim) TrimXmlBinding(xmlBindings);
			xmlBindings.Save(ResolvedOutputFilePath);
		}

		#endregion

		[Alias("Path")]
		[Parameter(Mandatory = true)]
		[ValidateNotNullOrEmpty]
		public string InputFilePath { get; set; }

		[Alias("Destination")]
		[Parameter(Mandatory = false)]
		[ValidateNotNullOrEmpty]
		public string OutputFilePath { get; set; }

		[Parameter(Mandatory = false)]
		public SwitchParameter Trim { get; set; }

		private string ResolvedInputPath => _resolvedInputFilePath ??= this.ResolvePath(InputFilePath);

		[SuppressMessage("ReSharper", "InvertIf")]
		private string ResolvedOutputFilePath => _resolvedOutputFilePath ??= OutputFilePath.IsNullOrEmpty()
			? Path.Combine(Path.GetDirectoryName(ResolvedInputPath)!, Path.GetFileNameWithoutExtension(ResolvedInputPath) + ".expanded.xml")
			: this.ResolvePath(OutputFilePath);

		private XslCompiledTransform TrimmingXslt => _trimmingXslt ??= ResourceManager.Load(
			Assembly.GetExecutingAssembly(),
			$"{typeof(ExpandApplicationBinding).FullName}.Trimmer.xslt",
			stream => {
				using (var xmlReader = XmlReader.Create(stream))
				{
					var xslt = new XslCompiledTransform(true);
					xslt.Load(xmlReader, XsltSettings.TrustedXslt, new XmlUrlResolver());
					return xslt;
				}
			});

		internal void TrimXmlBinding(XmlDocument xmlDocument)
		{
			using (var xmlReader = XmlReader.Create(xmlDocument.AsStream()))
			using (var writer = new StringWriter())
			using (var xmlWriter = XmlWriter.Create(writer, new() { OmitXmlDeclaration = true }))
			{
				TrimmingXslt.Transform(xmlReader, xmlWriter);
				writer.Flush();
				xmlDocument.LoadXml(writer.ToString());
			}
		}

		internal void UnescapeXmlTree(XmlNode node)
		{
			// to be unescaped, a text node must be a node's only child
			if (node.ChildNodes.Count == 1 && node.ChildNodes[0].NodeType == XmlNodeType.Text)
			{
				// as text node cannot have any child, this ongoing recursive iteration step can be ended if it does not need to be
				// unescaped --- this is a small optimization that is not required and merely avoids the subsequent foreach loop.
				// notice that we make sure there is either an unescaped closing or a self-closing tag in the text and not just
				// escaped opening or closing angular brackets ---i.e. &lt; or &gt;--- the absence of any closing tag denotes with
				// certainty an invalid XML fragment but their presence bears no guarantee though.
				if (!node.InnerXml.Contains("&lt;/") && !node.InnerXml.Contains("/&gt;")) return;
				var text = node.InnerText;
				try
				{
					const string xmlProcessingInstructionPattern = @"<\?xml .+\?>\s*";
					node.InnerXml = Regex.Replace(text, xmlProcessingInstructionPattern, string.Empty);
				}
				catch (XmlException exception)
				{
					WriteWarning($"Some, probably invalid, XML fragment could not be expanded properly.\r\n{exception}");
					node.InnerText = text;
					return;
				}
			}
			// also try to unescape current node's newly created XML subtree if it was a text node that has just been unescaped
			foreach (XmlNode childNode in node.ChildNodes)
			{
				UnescapeXmlTree(childNode);
			}
		}

		internal new virtual void WriteWarning(string message)
		{
			base.WriteWarning(message);
		}

		private static XslCompiledTransform _trimmingXslt;
		private string _resolvedInputFilePath;
		private string _resolvedOutputFilePath;
	}
}
