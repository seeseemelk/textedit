module textedit.viewmodels.mainviewmodel;

import textedit.views;
import textedit.services;
import textedit.models;
import textedit.utils.listener;
import textedit.mocks;
import textedit.repositories.recentfilesrepository;

import std.conv : to;
import std.concurrency;
import std.parallelism;
import std.range;

private version (unittest)
{
	Mocker mocker;
	MockSchedulerService schedulerService;

	MainViewModel testInstance()
	{
		mocker = new Mocker();
		mocker.allowDefaults();
		auto mainView = mocker.mock!IMainView();
		auto memoryService = mocker.mock!IMemoryService();
		auto timerService = mocker.mock!ITimerService();
		auto dialogService = mocker.mock!IDialogService();
		schedulerService = new MockSchedulerService();
		auto documentService = mocker.mock!IDocumentService();
		auto recentFilesRepository = mocker.mock!IRecentFilesRepository();
		return new MainViewModel(mainView, memoryService, timerService, dialogService, schedulerService, documentService,
			recentFilesRepository);
	}
}

class MainViewModel
{
	private IMainView _view;
	private IMemoryService _memoryService;
	private IDialogService _dialogService;
	private ISchedulerService _schedulerService;
	private IDocumentService _documentService;
	private IRecentFilesRepository _recentFilesRepository;
	private const(RecentFile)[] _recentFiles;
	private TextDocument _document = new TextDocument("");
	private Listener createListener;
	private Listener endListener;
	private uint _backgroundTaskCount;

	this(IMainView view, IMemoryService memoryService, ITimerService timerService, IDialogService dialogService,
			ISchedulerService schedulerService, IDocumentService documentService, IRecentFilesRepository recentFilesRepository)
	{
		_view = view;
		_memoryService = memoryService;
		_dialogService = dialogService;
		_schedulerService = schedulerService;
		_documentService = documentService;
		_recentFilesRepository = recentFilesRepository;

		_view.viewModel = this;
		_view.updateMemory;
		_view.show();

		timerService.createInterval(&_view.updateMemory, 100.msecs);

		_schedulerService.onTaskCreated(()
		{
			_backgroundTaskCount++;
			updateBackgroundTasks();
		});

		_schedulerService.onTaskEnded(()
		{
			_backgroundTaskCount--;
			updateBackgroundTasks();
		});

		_view.updateBackgroundTasks();
	}

	const(RecentFile[]) recentFiles() const
	{
		return _recentFiles;
	}

	@("recentFiles returns recent files")
	unittest
	{
		auto viewModel = testInstance();
		viewModel._recentFiles ~= RecentFile("file");
		assert(viewModel.recentFiles.length == 1);
		assert(viewModel.recentFiles[0] == RecentFile("file"));
	}

	size_t memoryUsed() const
	{
		return _memoryService.usedMemory;
	}

	@("memoryUsed returns used memory")
	unittest
	{
		auto viewModel = testInstance();
		mocker.expect(viewModel._memoryService.usedMemory).returns(1337);
		mocker.replay();
		assert(viewModel.memoryUsed == 1337);
	}

	size_t memoryTotal() const
	{
		return _memoryService.totalMemory;
	}

	@("memoryTotal returns total amount of memory")
	unittest
	{
		auto viewModel = testInstance();
		mocker.expect(viewModel._memoryService.totalMemory).returns(1337);
		mocker.replay();
		assert(viewModel.memoryTotal == 1337);
	}

	uint backgroundTaskCount() const
	{
		return _backgroundTaskCount;
	}

	@("backgroundTaskCount starts at zero")
	unittest
	{
		const viewModel = testInstance();
		assert(viewModel.backgroundTaskCount == 0);
	}

	@("backgroundTaskCount is 1 after a task is scheduled")
	unittest
	{
		auto viewModel = testInstance();
		schedulerService.schedule(SchedulerThread.background, {});
		assert(viewModel.backgroundTaskCount == 1);
	}

	@("backgroundTaskCount is 0 after a task ended")
	unittest
	{
		const viewModel = testInstance();
		schedulerService.schedule(SchedulerThread.background, {});
		schedulerService.execute(SchedulerThread.background);
		assert(viewModel.backgroundTaskCount == 0);
	}

	const(TextDocument) document()
	{
		return _document;
	}

	string content()
	{
		return _document.content;
	}

	void content(string content)
	{
		_document.content = content;
	}

	void onOpen()
	{
		_schedulerService.schedule(SchedulerThread.background, {
			if (canChangeDocument("Are you sure you want to open a new document?\nYou still have unsaved changes"))
			{
				_dialogService.showOpenFileDialog().ifPresent((filename)
				{
					_document = _documentService.openDocument(filename);
					updateDocument();
				});
			}
		});
	}

	void onSave()
	{
		_schedulerService.schedule(SchedulerThread.background,
		{
			if (_document.path.empty)
			{
				auto path = _dialogService.showSaveFileDialog();
				if (path.isEmpty)
					return;
				path.ifPresent((path)
				{
					_document.path = path;
				});
			}
			_documentService.saveDocument(_document);
		});
	}

	void onSaveAs()
	{
		_schedulerService.schedule(SchedulerThread.background,
		{
			const path = _dialogService.showSaveFileDialog();
			path.ifPresent((path)
			{
				_document.path = path;
				_documentService.saveDocument(_document);
			});
		});
	}

	void onNew()
	{
		_schedulerService.schedule(SchedulerThread.background,
		{
			if (canChangeDocument("Are you sure you want to create a new document?\nYou still have an unsaved document."))
			{
				_document = new TextDocument("");
				updateDocument();
			}
		});
	}

	void onDocumentChanged()
	{
		_document.saved = false;
	}

	private void updateDocument()
	{
		_schedulerService.schedule(SchedulerThread.ui,
		{
			_view.updateDocument();
		});
	}

	private bool canChangeDocument(string message)
	{
		if (document.saved)
			return true;
		return _dialogService.showConfirmationDialog(message).orElse(false);
	}

	private void updateBackgroundTasks()
	{
		_schedulerService.scheduleOnUI(&_view.updateBackgroundTasks);
	}
}