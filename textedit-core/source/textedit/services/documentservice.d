module textedit.services.documentservice;

import textedit.models;

import std.file;

/// Describes a file somewhere.
@safe interface IFile
{
	/// The name of the file.
	string name() const;

	/// The path to the file excluding the filename.
	string path() const;
}

/// Describes a directory somewhere.
@safe interface IDirectory
{
	/// The name of the directory.
	string name() const;
	
	/// The path to the directory excluding the directory name.
	string path() const;
	
	/// A list of subdirectories.
	IDirectory[] directories();
	
	/// A list of child files.
	IFile[] files();

	/// Returns: The number of child directories and files.
	/*size_t count()
	{
		return directories.length + files.length;
	}*/
}

/** 
 * A service that manages text documents.
 */
@safe interface IDocumentService
{
	/** 
	 * Opens a text document.
	 * Params:
	 *   filename = The path to the file to open.
	 * Returns: The text document.
	 */
	TextDocument openDocument(string filename);

	/** 
	 * Saves a document.
	 * Params:
	 *   document = The document to save.
	 */
	void saveDocument(TextDocument document);

	/**
	 * Gets a directory descriptor for a given path.
	 * Params:
	 *   path = The path to the directory.
	 * Returns: A descriptor of the directory.
	 */
	IDirectory getDirectory(string path);
}

/// The standard implementation of the `IDocumentService`.
@safe class DocumentService : IDocumentService
{
	private class DirectoryDescriptor : IDirectory
	{
		private const string _fullPath;

		this(string fullPath)
		{
			_fullPath = fullPath;
		}

		override string name() const
		{
			return _fullPath;
		}

		override string path() const
		{
			return _fullPath;
		}

		override IDirectory[] directories()
		{
			assert(0);
		}

		override IFile[] files()
		{
			assert(0);
		}
	}

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
		auto path = tempDir ~ "/textedit-unittest-file1.txt";
		write(path, "foobar");
		const document = service.openDocument(path);
		assert(document.path == path);
		assert(document.content == "foobar");
	}

	override void saveDocument(TextDocument document) const
	{
		write(document.path, document.content);
		document.saved = true;
	}

	@("saveDocument saves a document and sets saved properties")
	unittest
	{
		auto service = new DocumentService;
		auto path = tempDir ~ "/textedit-unittest-file2.txt";
		auto document = new TextDocument(path, "foobar");
		document.saved = false;
		service.saveDocument(document);
		assert(path.readText == "foobar");
		assert(document.saved == true);
	}

	override IDirectory getDirectory(string path)
	{
		DirectoryDescriptor descriptor = new DirectoryDescriptor(path);
		return descriptor;
	}

	@("getDirectory returns a list of all directories and files")
	unittest
	{
		auto service = new DocumentService;
		const descriptor = service.getDirectory("/path/to/somewhere");
		assert(descriptor.name == "somewhere");
	}
}