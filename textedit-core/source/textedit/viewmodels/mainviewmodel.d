module textedit.viewmodels.mainviewmodel;

import textedit.views;
import textedit.services;
import textedit.models;
import textedit.utils.listener;

import std.conv : to;
import std.concurrency;
import std.parallelism;

class MainViewModel
{
	private IMainView _view;
	private IMemoryService _memoryService;
	private IDialogService _dialogService;
	private ISchedulerService _schedulerService;
	private IDocumentService _documentService;
	private TextDocument _document = new TextDocument("");
	private Listener createListener;
	private Listener endListener;
	private uint _backgroundTaskCount;

	this(IMainView view, IMemoryService memoryService, ITimerService timerService, IDialogService dialogService,
			ISchedulerService schedulerService, IDocumentService documentService)
	{
		_view = view;
		_memoryService = memoryService;
		_dialogService = dialogService;
		_schedulerService = schedulerService;
		_documentService = documentService;

		_view.viewModel = this;
		_view.updateMemory;
		_view.show();

		timerService.createInterval(&_view.updateMemory, 100.msecs);

		_schedulerService.onTaskCreated(
		{
			_backgroundTaskCount++;
			updateBackgroundTasks();
		});

		_schedulerService.onTaskEnded(
		{
			_backgroundTaskCount--;
			updateBackgroundTasks();
		});

		_view.updateBackgroundTasks();
	}

	size_t memoryUsed() const
	{
		return _memoryService.usedMemory;
	}

	size_t memoryTotal() const
	{
		return _memoryService.totalMemory;
	}

	uint backgroundTaskCount() const
	{
		return _backgroundTaskCount;
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
			_dialogService.showOpenFileDialog().ifPresent((filename)
			{
				_document = _documentService.openDocument(filename);
				_view.updateDocument();
			});
		});
	}

	void onSave()
	{
		_schedulerService.schedule(SchedulerThread.background, {
			if (_document.path == "")
				assert(0, "Cannot saved document that wasn't opened");
			_documentService.saveDocument(_document);
		});
	}

	private void updateBackgroundTasks()
	{
		_schedulerService.scheduleOnUI(&_view.updateBackgroundTasks);
	}
}