module textedit.gtk.services.dialogservice;

import textedit.services;
import textedit.utils.task;
import textedit.utils.maybe;

import gtk.FileChooserNative;
import std.stdio;

class GtkDialogService : IDialogService
{
	private ISchedulerService _scheduler;

	this(ISchedulerService scheduler)
	{
		_scheduler = scheduler;
	}

	override Maybe!string showOpenFileDialog()
	{
		auto task = Task!(Maybe!string)(() {
			auto dialog = new FileChooserNative("Open File", null, GtkFileChooserAction.OPEN, null, null);
			immutable result = dialog.run();
			if (result == ResponseType.ACCEPT)
			{
				string filename = dialog.getFilename;
				return Maybe!string.of(filename);
			}
			return Maybe!string.empty();
		});
		task.scheduleOnUI(_scheduler);

		return task.get();
	}
}