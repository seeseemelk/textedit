module textedit.services.schedulerservice;

import textedit.streams.future;

/** 
 * A service that allows for threads and callbacks to be scheduled.
 */
interface ISchedulerService
{
	/**
	 * Executes a task on the UI thread.
	 * This should be used sparingly.
	 * Params:
	 *  callback = The task to run on the UI thread.
	 */
	void executeOnUI(void delegate() callback);

	/**
	 * Executes a task in the background.
	 * Params:
	 *  callback = The task to run in the background.
	 */
	void executeAsync(void delegate() callback);
}