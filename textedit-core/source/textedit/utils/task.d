module textedit.utils.task;

import textedit.services.schedulerservice;
import textedit.mocks;

import core.sync.event;

/** 
 * Represents a task that might be executed on a diferent thread.
 */
struct Task(T)
{
	private Event _event;
	private T delegate() _callback;
	private T _value;

	/** 
	 * Creates a new task.
	 * Params:
	 *   callback = A delegate that will be executed on the thread.
	 */
	this(T delegate() callback)
	{
		_event.initialize(true, false);
		_callback = callback;
	}

	/** 
	 * Blocks and returns the result of the task.
	 * Returns: Blocks until the task completes, and returns the result of the task.
	 */
	T get()
	{
		_event.wait();
		return _value;
	}

	/** 
	 * Schedules the task to run on the UI thread.
	 * Params:
	 *   service = The service that will schedule the task.
	 */
	void scheduleOnUI(ISchedulerService service)
	{
		service.executeOnUI(() {
			_value = _callback();
			_event.set();
		});
	}
}

@("Task(T).scheduleOnUI executes on the UI thread.")
unittest
{
	auto mocker = new Mocker();
	auto scheduler = mocker.mock!ISchedulerService;
	string value;
	mocker.expect(scheduler.executeOnUI(null)).ignoreArgs.action((void delegate() callback) {
		callback();
	});
	mocker.replay();
	auto task = Task!string({
		value = "foo";
		return "bar";
	});
	task.scheduleOnUI(scheduler);
	assert(value == "foo");
	assert(task.get == "bar");
}