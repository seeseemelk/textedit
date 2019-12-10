module textedit.services.documentservice;

import textedit.models;

import std.file;

/** 
 * A service that manages text documents.
 */
interface IDocumentService
{
	/** 
	 * Opens a text document.
	 * Params:
	 *    filename = The path to the file to open.
	 * Returns: The text document.
	 */
	TextDocument openDocument(string filename);
}

class DocumentService : IDocumentService
{
	override TextDocument openDocument(string filename)
	{
		immutable content = readText(filename);
		auto document = new TextDocument(filename);
		document.content = content;
		return document;
	}
}