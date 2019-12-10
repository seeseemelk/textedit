module textedit.gtk.services.dialogservice;

import textedit.services;
import textedit.streams.future;

import gtk.FileChooserNative;
import std.stdio;

class GtkDialogService : IDialogService
{
	private ISchedulerService _scheduler;

	this(ISchedulerService scheduler)
	{
		_scheduler = scheduler;
	}

	override string showOpenFileDialog()
	{
		auto task = Task!string(() {
			auto dialog = new FileChooserNative("Open File", null, GtkFileChooserAction.OPEN, null, null);
			immutable result = dialog.run();
			if (result == ResponseType.ACCEPT)
			{
				string filename = dialog.getFilename;
				return filename;
			}
			return "";
		});
		task.scheduleOnUI(_scheduler);

		return task.get();
	}
}