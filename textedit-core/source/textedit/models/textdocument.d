module textedit.models.textdocument;

/**
 * Represents a text document.
 */
class TextDocument
{
	private string _filename;
	private string _content;

	/** 
	 * Creates a new text document.
	 * Params:
	 *   filename = The path to the file.
	 */
	this(string filename)
	{
		_filename = filename;
	}

	/** 
	 * Creates a new text document with content.
	 * Params:
	 *   filename = The path to the file.
	 *   content = The content of the file.
	 */
	this(string filename, string content)
	{
		this(filename);
		_content = content;
	}

	/**
	 * Returns: The content of the document.
	 */
	string content()
	{
		return _content;
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

	/**
	 * Returns: The path to the file.
	 */
	string filename()
	{
		return filename;
	}
}