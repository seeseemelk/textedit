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
	override TextDocument openDocument(string filename) const
	{
		immutable content = readText(filename);
		auto document = new TextDocument(filename);
		document.content = content;
		return document;
	}

	@("openDocument returns a document")
	unittest
	{
		auto service = new DocumentService;
		auto path = tempDir ~ "/file.txt";
		write(path, "foobar");
		const document = service.openDocument(path);
		assert(document.path == path);
		assert(document.content == "foobar");
	}
}