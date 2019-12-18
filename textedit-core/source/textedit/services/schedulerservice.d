module textedit.services.schedulerservice;

import textedit.utils.listener;

/** 
 * A set of possible threads a task can be scheduled on.
 */
enum SchedulerThread
{
	ui,
	background
}

/** 
 * A service that allows for threads and callbacks to be scheduled.
 */
interface ISchedulerService
{
	/**
	 * Executes a task on a given thread.
	 * Params:
	 *  thread = The thread on which the task should be ran.
	 *  callback = The task to run on the thread..
	 */
	void schedule(SchedulerThread thread, void delegate() callback);

	/** 
	 * Executes a task on the UI thread.
	 * This should be used sparingly.
	 * Params:
	 *   callback = The task to run on the UI thread.
	 */
	final void scheduleOnUI(void delegate() callback)
	{
		schedule(SchedulerThread.ui, callback);
	}

	/**
	 * Creates a listener that is called whenever a task is created.
	 */
	Listener onTaskCreated(void delegate() callback);

	/** 
	 * Creates a listener that is called whenever a task is ended.
	 */
	Listener onTaskEnded(void delegate() callback);
}

/// A mock `SchedulerService`
version(unittest) class MockSchedulerService : ISchedulerService
{
	private alias Callbacks = void delegate()[];

	private Callbacks[SchedulerThread] _scheduled;
	private ListenerContainer!() _onTaskCreated;
	private ListenerContainer!() _onTaskEnded;

	override void schedule(SchedulerThread thread, void delegate() callback)
	{
		_scheduled[thread] ~= callback;
		_onTaskCreated.fire();
	}

	@("schedule adds thread")
	unittest
	{
		import std.algorithm : any;
		auto service = new MockSchedulerService();
		void delegate() callback = () {};
		service.schedule(SchedulerThread.ui, callback);

		auto callbacks = service._scheduled[SchedulerThread.ui];
		assert(callbacks.length == 1);
		assert(callbacks[0] == callback);
	}

	@("schedule fires onTaskCreated listener")
	unittest
	{
		auto service = new MockSchedulerService();
		bool fired = false;
		service.onTaskCreated({fired = true;});
		void delegate() callback = () {};
		service.schedule(SchedulerThread.ui, callback);
		assert(fired == true);
	}

	override Listener onTaskCreated(void delegate() callback)
	{
		return _onTaskCreated.add(callback);
	}

	override Listener onTaskEnded(void delegate() callback)
	{
		return _onTaskEnded.add(callback);
	}

	/**
	 * Executes all scheduled callbacks for a given thread.
	 * Params:
	 *  thread = The thread for which callbacks should be ran.
	 */
	void execute(SchedulerThread thread)
	{
		auto callbacks = _scheduled[SchedulerThread.ui];
		_scheduled[SchedulerThread.ui] = [];

		foreach (callback; callbacks)
		{
			callback();
			_onTaskEnded.fire();
		}
	}

	@("execute runs all scheduled callbacks for a given thread")
	unittest
	{
		auto service = new MockSchedulerService();
		bool fired = false;
		service.schedule(SchedulerThread.ui, {fired = true;});
		assert(fired == false);
		service.execute(SchedulerThread.ui);
		assert(fired == true);
		assert(service._scheduled[SchedulerThread.ui].length == 0);
	}

	@("execute fires onTaskEnded listener")
	unittest
	{
		auto service = new MockSchedulerService();
		bool fired = false;
		service.onTaskEnded({fired = true;});
		service.schedule(SchedulerThread.ui, {});
		assert(fired == false);
		service.execute(SchedulerThread.ui);
		assert(fired == true);
	}

	@("execute will only fire a callback once")
	unittest
	{
		auto service = new MockSchedulerService();
		int fired = 0;
		service.schedule(SchedulerThread.ui, {fired++;});
		service.execute(SchedulerThread.ui);
		service.execute(SchedulerThread.ui);
		assert(fired == 1);
	}
}