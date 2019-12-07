module textedit.gtk.app;

import std.stdio;

import textedit.gtk.views.mainview;
import textedit.gtk.services.timerservice;
import textedit.gtk.services.dialogservice;
import textedit.gtk.services.schedulerservice;

import textedit.services;
import textedit.views;
import textedit.core;

import gio.Application : GioApplication = Application;
import gtk.Application;

import poodinis;

private version (linux) void enableSegfaultErrors()
{
	import etc.linux.memoryerror : registerMemoryErrorHandler;
	static if (is(typeof(registerMemoryErrorHandler)))
		registerMemoryErrorHandler();
}

version (unittest) {} else
{
	int main(string[] args)
	{
		version (linux) enableSegfaultErrors();

		Application application = new Application("space.ruska.textedit", GApplicationFlags.FLAGS_NONE);
		MainView window = new MainView(application);
		application.addOnActivate((gioApplication) {
			window.onActivate();
			bootTextedit((container) {
				container.register!(Application).existingInstance(application);
				container.register!(IMainView, MainView).existingInstance(window);
				container.register!(TimerService);
				container.register!(DialogService);
				container.register!(SchedulerService);
			});
		});
		application.addOnStartup((gioApplication) {
			window.onStartup();
		});
		return application.run(args);
	}
}

@("cool")
unittest
{
	writeln("Cool");
}
