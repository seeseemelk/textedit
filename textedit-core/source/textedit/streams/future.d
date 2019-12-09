module textedit.streams.future;

import textedit.services.schedulerservice;

import core.sync.event;

class Future(T)
{
	private Event _event;
	private shared T delegate() _callback;
	private shared T _value;

	this(T delegate() callback)
	{
		_event.initialize(true, false);
		_callback = callback;
	}

	T get()
	{
		_event.wait();
		return _value;
	}

	void runOnUI(ISchedulerService service)
	{
		service.executeOnUI(() {
			_value = _callback();
			_event.set();
		});
	}
}