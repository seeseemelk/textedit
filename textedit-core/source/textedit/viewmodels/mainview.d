module textedit.viewmodels.mainview;

import textedit.views;
import textedit.services;

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
	private string _content;

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
	}

	size_t memoryUsed()
	{
		return _memoryService.usedMemory;
	}

	size_t memoryTotal()
	{
		return _memoryService.totalMemory;
	}

	string content()
	{
		return _content;
	}

	void onOpen()
	{
		_schedulerService.executeAsync({
			immutable filename = _dialogService.showOpenFileDialog();
			_content = _documentService.openDocument(filename).content;
			_view.updateContent();
		});
	}
}