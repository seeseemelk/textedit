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