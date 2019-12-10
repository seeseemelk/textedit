module textedit.services.timerservice;

public import core.time;

@safe interface ITimerService
{
	void createInterval(void delegate() callback, Duration duration);
}