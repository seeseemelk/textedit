module textedit.models.textdocument;

/**
 * Represents a text document.
 */
class TextDocument
{
	private string _filename;
	private string _content;

	this(string filename)
	{
		_filename = filename;
	}

	this(string filename, string content)
	{
		this(filename);
		_content = content;
	}

	string content()
	{
		return content;
	}

	void content(string content)
	{
		_content = content;
	}

	string filename()
	{
		return filename;
	}
}