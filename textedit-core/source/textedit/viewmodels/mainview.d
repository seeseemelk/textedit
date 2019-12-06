module textedit.viewmodels.mainview;

import textedit.views;
import textedit.services;

import std.conv : to;

class MainViewModel
{
	private IMainView _view;
	private IMemoryService _memoryService;
	private string _content;

	this(IMainView view, IMemoryService memoryService, ITimerService timerService)
	{
		_view = view;
		_memoryService = memoryService;

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

	void content(string content)
	{
		_content = content;
	}
}