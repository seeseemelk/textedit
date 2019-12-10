module textedit.viewmodels.mainviewmodel;

import textedit.views;
import textedit.services;
import textedit.models;

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
		_schedulerService.executeAsync({
			immutable filename = _dialogService.showOpenFileDialog();
			_document = _documentService.openDocument(filename);
			_view.updateDocument();
		});
	}

	void onSave()
	{
		_schedulerService.executeAsync({
			if (_document.path == "")
				assert("Cannot saved document that wasn't opened");
			_documentService.saveDocument(_document);
		});
	}
}