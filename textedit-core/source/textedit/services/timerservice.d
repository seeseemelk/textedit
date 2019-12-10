module textedit.services.timerservice;

public import core.time;

interface ITimerService
{
	void createInterval(void delegate() callback, Duration duration);
}