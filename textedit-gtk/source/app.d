import std.stdio;

import textedit.gtk.mainwindow;
import gio.Application : GioApplication = Application;
import gtk.Application;

private version (linux) void enableSegfaultErrors()
{
	import etc.linux.memoryerror;
	static if (is(typeof(registerMemoryErrorHandler)))
		registerMemoryErrorHandler();
}

version (unittest) {} else
{
	int main(string[] args)
	{
		version (linux) enableSegfaultErrors();

		//writeln("Edit source/app.d to start your project.");
		Application application = new Application("space.ruska.textedit", GApplicationFlags.FLAGS_NONE);
		MainWindow window = new MainWindow(application);

		application.addOnActivate((gioApplication) {
			window.onActivate();
		});
		application.addOnStartup((gioApplication) {
			window.onStartup();
		});
		return application.run(args);
		//MainWindow window = new MainWindow(application);
	}
}

@("cool")
unittest
{
	writeln("Cool");
}
