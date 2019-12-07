module textedit.gtk.services.timerservice;

import glib.Timeout;

import core.time;

class TimerService
{
	void createInterval(void delegate() callback, Duration duration)
	{
		auto timer = new Timeout(cast(uint) duration.total!"msecs", makeCallback(callback));
	}

	private bool delegate() makeCallback(void delegate() callback)
	{
		return () {
			callback();
			return true;
		};
	}
}