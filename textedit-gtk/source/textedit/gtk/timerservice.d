module textedit.gtk.timerservice;

import textedit.services.timerservice;

import glib.Timeout;

class GtkTimerService : ITimerService
{
	override void createInterval(void delegate() callback, Duration duration)
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