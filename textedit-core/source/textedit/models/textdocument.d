module textedit.models.textdocument;

import std.range : empty;

/**
 * Represents a text document.
 */
@safe class TextDocument
{
	private string _path;
	private string _content = "";
	private bool _saved = true;

	/** 
	 * Creates a new text document.
	 * Params:
	 *   path = The path to the file.
	 */
	this(string path)
	{
		_path = path;
	}

	@("constructor sets path")
	unittest
	{
		auto document = new TextDocument("/path");
		assert(document._path == "/path");
	}

	/** 
	 * Creates a new text document with content.
	 * Params:
	 *   path = The path to the file.
	 *   content = The content of the file.
	 */
	this(string path, string content)
	{
		this(path);
		_content = content;
	}

	@("constructor sets path and content")
	unittest
	{
		auto document = new TextDocument("/path", "Hello, world!");
		assert(document._path == "/path");
		assert(document._content == "Hello, world!");
	}

	/**
	 * Returns: The content of the document.
	 */
	string content() const
	{
		return _content;
	}

	@("content returns content")
	unittest
	{
		auto document = new TextDocument("/", "foobar");
		assert(document.content() == "foobar");
	}

	/** 
	 * Sets the content of the document.
	 * Params:
	 *   content = The content of the document.
	 */
	void content(string content)
	{
		_content = content;
	}

	@(".content sets content")
	unittest
	{
		auto document = new TextDocument("/");
		document.content("foobar");
		assert(document._content == "foobar");
	}

	/**
	 * Returns: The path to the file.
	 */
	string path() const
	{
		return _path;
	}

	@("path sets the path")
	unittest
	{
		auto document = new TextDocument("/foo/bar");
		assert(document.path() == "/foo/bar");
	}

	bool hasPath() const
	{
		return !_path.empty;
	}

	@("hasPath returns false for a document with an empty path")
	unittest
	{
		auto document = new TextDocument("");
		assert(document.hasPath == false);
	}

	@("hasPath returns true for a document with a path")
	unittest
	{
		auto document = new TextDocument("document.txt");
		assert(document.hasPath == true);
	}

	bool saved() const
	{
		return _saved;
	}

	void saved(bool saved)
	{
		_saved = saved;
	}

	@("saved returns false if the document is not saved")
	unittest
	{
		auto document = new TextDocument("");
		document.saved = false;
		assert(document.saved == false);
		document.saved = true;
		assert(document.saved == true);
	}
}