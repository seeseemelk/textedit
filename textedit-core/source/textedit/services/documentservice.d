module textedit.services.documentservice;

import textedit.models;

import std.file;

interface IDocumentService
{
	TextDocument openDocument(string filename);
}

class DocumentService : IDocumentService
{
	override TextDocument openDocument(string filename)
	{
		immutable content = readText(filename);
		return new TextDocument(filename, content);
	}
}