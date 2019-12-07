module textedit.services.documentservice;

import textedit.models;

import std.file;

class DocumentService
{
	void openDocument(string filename, void delegate(TextDocument) callback)
	{
		immutable content = readText(filename);
		//return new TextDocument(filename, content);
	}
}