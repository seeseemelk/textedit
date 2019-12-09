module textedit.gtk.services.dialogservice;

import textedit.services;

import gtk.FileChooserNative;
import std.stdio;

class GtkDialogService : IDialogService
{
	private ISchedulerService _scheduler;

	this(ISchedulerService scheduler)
	{
		_scheduler = scheduler;
	}

	override void showOpenFileDialog(void delegate(string) onItemSelected)
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