module textedit.gtk.services.dialogservice;

import textedit.services;
import textedit.utils.task;
import textedit.utils.maybe;

import gtk.FileChooserNative;
import gtk.MessageDialog;
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
		auto task = Task!(Maybe!string)(()
		{
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

	override Maybe!string showSaveFileDialog()
	{
		auto task = Task!(Maybe!string)(()
		{
			auto dialog = new FileChooserNative("Open File", null, GtkFileChooserAction.SAVE, null, null);
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

	override Maybe!bool showConfirmationDialog(string message)
	{
		auto task = Task!(Maybe!bool)(()
		{
			auto dialog = new MessageDialog(null, GtkDialogFlags.MODAL, GtkMessageType.QUESTION, GtkButtonsType.YES_NO, message);
			auto result = dialog.run();
			dialog.hide();
			if (result == ResponseType.YES)
				return Maybe!bool.of(true);
			else if (result == ResponseType.CANCEL)
				return Maybe!bool.of(false);
			else
				return Maybe!bool.empty();
		});
		task.scheduleOnUI(_scheduler);
		return task.get();
	}
}