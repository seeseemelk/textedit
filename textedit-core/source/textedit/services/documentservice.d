module textedit.services.documentservice;

import textedit.models;

import std.file;

interface IDocumentService
{
	void openDocument(string filename, void delegate(TextDocument) callback);
}

class DocumentService : IDocumentService
{
	override void openDocument(string filename, void delegate(TextDocument) callback)
	{
		immutable content = readText(filename);
		//return new TextDocument(filename, content);
	}
}