module textedit.viewmodels.mainview;

import textedit.views;
import textedit.services;

import std.conv : to;
import std.concurrency;
import std.parallelism;
import core.time;

class MainViewModel
{
	private IMainView _view;
	private MemoryService _memoryService;
	private DialogService _dialogService;

	this(IMainView view, MemoryService memoryService, TimerService timerService, DialogService dialogService)
	{
		_view = view;
		_memoryService = memoryService;
		_dialogService = dialogService;

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

	void onOpen()
	{
		auto task = task({
			_dialogService.showOpenFileDialog((file) {

			});
		});
		task.executeInNewThread();
	}
}