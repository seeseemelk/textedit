module textedit.services.schedulerservice;

/** 
 * A set of possible threads a task can be scheduled on.
 */
enum SchedulerThread
{
	UI,
	Background
}

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
	void schedule(SchedulerThread thread, void delegate() callback);

	/**
	 * Returns a count of the currently running tasks.
	 * Returns: The number of currently running tasks.
	 */
	int countRunningTasks();

	/**
	 * Creates a listener that is called whenever a task is created.
	 */
	TaskCreatedListener onTaskCreated(void delegate() callback);

	/** 
	 * Creates a listener that is called whenever a task is removed
	 */
	TaskStoppedListener onTaskStopped(void delegate() callback);
}

interface TaskCreatedListener {}