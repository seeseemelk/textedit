module textedit.gtk.mainview;

import textedit.viewmodels.mainview;
import textedit.views;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Label;
import gtk.TextView;
import gtk.ScrolledWindow;
import gio.Menu;
import gio.MenuItem;
import gio.SimpleAction;
import glib.Variant;

import std.conv : to;

class MainView : IMainView
{
	private Application _application;
	private ApplicationWindow _window;
	private Menu _menu;
	private MainViewModel _viewModel;
	private Label _memoryLabel;

	this(Application application)
	{
		_application = application;
	}

	override void show()
	{
		_window.showAll();
	}

	override void viewModel(MainViewModel viewModel)
	{
		_viewModel = viewModel;
	}

	override void updateMemory()
	{
		auto used = (_viewModel.memoryUsed / 1024).to!string;
		auto total = (_viewModel.memoryTotal / 1024).to!string;
		_memoryLabel.setText(used ~ " KiB / " ~ total ~ " KiB");
	}

	void onActivate()
	{
		_application.setMenubar(_menu);
		_window = new ApplicationWindow(_application);
		_window.setTitle("TextEdit");

		auto box = new Box(GtkOrientation.VERTICAL, 5);
		_window.add(box);

		_memoryLabel = new Label("");
		_memoryLabel.setAlignment(1, 0.5);
		box.packEnd(_memoryLabel, false, false, 4);

		auto textView = new TextView();
		textView.setEditable(true);

		auto scrolledWindow = new ScrolledWindow(PolicyType.AUTOMATIC, PolicyType.ALWAYS);
		scrolledWindow.add(textView);
		scrolledWindow.setBorderWidth(4);
		box.packStart(scrolledWindow, true, true, 0);
	}

	void onStartup()
	{
		auto fileMenu = new Menu();

		addAction("open", &onOpen);
		auto fileSection = new Menu();
		fileSection.append("Open", "app.open");
		fileMenu.appendSection(null, fileSection);

		addAction("quit", &onQuit);
		auto section = new Menu();
		section.append("Quit", "app.quit");
		fileMenu.appendSection(null, section);

		_menu = new Menu();
		_menu.appendSubmenu("File", fileMenu);
	}

	void onQuit(Variant variant, SimpleAction action)
	{
		_window.close();
	}

	void onOpen(Variant variant, SimpleAction action)
	{

	}

	private void addAction(string name, void delegate(Variant, SimpleAction) callback)
	{
		auto action = new SimpleAction(name, null);
		action.addOnActivate(callback);
		_application.addAction(action);
	}
}