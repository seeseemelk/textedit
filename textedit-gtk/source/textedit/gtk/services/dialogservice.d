module textedit.gtk.services.dialogservice;

import textedit.services;
import textedit.streams;

class GtkDialogService : IDialogService
{
	override Mono!string showOpenFileDialog()
	{
		return Mono!string.empty();
	}
}