module textedit.gtk.documenteditor;

import gtk.TextView;
import cairo.FontOption;

class DocumentEditor
{
	private TextView _textView;

	this()
	{
		_textView = new TextView();
		_textView.modifyFont("monospace", 11);
	}

	TextView widget()
	{
		return _textView;
	}
}