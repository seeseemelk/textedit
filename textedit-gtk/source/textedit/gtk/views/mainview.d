module textedit.gtk.views.mainview;

import textedit.viewmodels.mainviewmodel;
import textedit.views;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Label;
import gtk.TextView;
import gtk.ScrolledWindow;
import gtk.AboutDialog;
import gtk.c.types;
import gio.Menu;
import gio.MenuItem;
import gio.SimpleAction;
import glib.Variant;

import std.string;

class MainView : IMainView
{
	private Application _application;
	private ApplicationWindow _window;
	private Menu _menu;
	private MainViewModel _viewModel;
	private Label _memoryLabel;
	private Label _tasksLabel;
	private TextView _textView;

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
		auto used = _viewModel.memoryUsed / 1024;
		auto total = _viewModel.memoryTotal / 1024;
		_memoryLabel.setText(format!"%d KiB / %d KiB"(used, total));
	}

	override void updateDocument()
	{
		_textView.getBuffer().setText(_viewModel.document.content);
	}

	override void updateBackgroundTasks()
	{
		const tasks = _viewModel.backgroundTaskCount();
		_tasksLabel.setText(format!"Tasks: %d"(tasks));
	}

	void onActivate()
	{
		_application.setMenubar(_menu);
		_window = new ApplicationWindow(_application);
		_window.setTitle("TextEdit");

		auto box = new Box(GtkOrientation.VERTICAL, 5);
		_window.add(box);

		auto hbox = new Box(GtkOrientation.HORIZONTAL, 15);
		box.packEnd(hbox, false, false, 4);

		_memoryLabel = new Label("");
		_memoryLabel.setAlignment(1, 0.5);
		hbox.packEnd(_memoryLabel, false, false, 4);

		_tasksLabel = new Label("");
		_tasksLabel.setAlignment(1, 0.5);
		hbox.packEnd(_tasksLabel, false, false, 4);

		_textView = new TextView();
		_textView.setEditable(true);

		auto scrolledWindow = new ScrolledWindow(PolicyType.AUTOMATIC, PolicyType.ALWAYS);
		scrolledWindow.add(_textView);
		scrolledWindow.setBorderWidth(4);
		box.packStart(scrolledWindow, true, true, 0);
	}

	void onStartup()
	{
		_menu = new Menu();

		createFileMenu();
		createAboutMenu();
	}

	private void onQuit(Variant _, SimpleAction __)
	{
		_window.close();
	}

	private void onOpen(Variant _, SimpleAction __)
	{
		_viewModel.onOpen();
	}

	private void onSave(Variant _, SimpleAction __)
	{
		_viewModel.content = _textView.getBuffer().getText();
		_viewModel.onSave();
	}

	private void onAbout(Variant _, SimpleAction __)
	{
		auto dialog = new AboutDialog();
		dialog.setProgramName("TextEdit");
		dialog.setLicenseType(GtkLicense.GPL_3_0);
		dialog.setAuthors(["Sebastiaan de Schaetzen"]);
		dialog.setWebsite("https://github.com/seeseemelk/textedit");
		dialog.setWebsiteLabel("View on GitHub");
		dialog.setLogoIconName("accessories-text-editor");
		dialog.run();
		dialog.hide();
	}

	private void addAction(string name, void delegate(Variant, SimpleAction) callback)
	{
		auto action = new SimpleAction(name, null);
		action.addOnActivate(callback);
		_application.addAction(action);
	}

	private void createFileMenu()
	{
		auto fileMenu = new Menu();

		auto fileSection = new Menu();
		fileMenu.appendSection(null, fileSection);

		addAction("open", &onOpen);
		fileSection.append("Open", "app.open");

		addAction("save", &onSave);
		fileSection.append("Save", "app.save");

		auto section = new Menu();
		fileMenu.appendSection(null, section);

		addAction("quit", &onQuit);
		section.append("Quit", "app.quit");

		_menu.appendSubmenu("File", fileMenu);
	}

	private void createAboutMenu()
	{
		auto menu = new Menu();

		auto section  = new Menu();
		menu.appendSection(null, section);

		addAction("about", &onAbout);
		section.append("About", "app.about");

		_menu.appendSubmenu("Help", menu);
	}
}