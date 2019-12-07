module textedit.gtk.services.dialogservice;

import textedit.services;

import gtk.FileChooserNative;
import std.stdio;

class DialogService
{
	private SchedulerService _scheduler;

	this(SchedulerService scheduler)
	{
		_scheduler = scheduler;
	}

	void showOpenFileDialog(void delegate(string) onItemSelected)
	{
		auto result = _scheduler.executeOnUI!string({
			auto dialog = new FileChooserNative("Open File", null, GtkFileChooserAction.OPEN, null, null);
			immutable result = dialog.run();
			if (result == ResponseType.ACCEPT)
			{
				string filename = dialog.getFilename;
				return filename;
			}
			return "";
		});

		auto filename = result.get();
		writefln!"File %s was selected"(filename);
	}
}