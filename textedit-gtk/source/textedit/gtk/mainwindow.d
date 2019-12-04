module textedit.gtk.mainwindow;

import gtk.Application;
import gtk.ApplicationWindow;
import gio.Menu;
import gio.MenuItem;
import gio.SimpleAction;
import glib.Variant;

class MainWindow
{
	private Application application;
	private ApplicationWindow window;
	private Menu menu;

	this(Application application)
	{
		this.application = application;
	}

	void onActivate()
	{
		application.setMenubar(menu);
		window = new ApplicationWindow(application);
		window.setTitle("TextEdit");
		window.showAll();
	}

	void onStartup()
	{
		addAction("quit", &onQuit);

		auto fileMenu = new Menu();
		
		auto quitItem = new MenuItem("Quit", "app.quit");
		quitItem.setActionAndTargetValue("app.quit", null);
		fileMenu.appendItem(quitItem);

		menu = new Menu();
		menu.appendSubmenu("File", fileMenu);
	}

	void onQuit(Variant variant, SimpleAction action)
	{
		window.close();
	}

	private void addAction(string name, void delegate(Variant, SimpleAction) callback)
	{
		auto action = new SimpleAction(name, null);
		action.addOnActivate(callback);
		application.addAction(action);
	}
}