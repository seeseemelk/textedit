module textedit.services.timerservice;

public import core.time;

/** 
 * A service that can be used to create timers.
 */
interface ITimerService
{
	/**
	 * Creates a timer.
	 * Params:
	 *  callback = A callback to execute each time the timer fires.
	 *  duration = The duration between each execution of the timer.
	 */
	void createInterval(void delegate() callback, Duration duration);
}