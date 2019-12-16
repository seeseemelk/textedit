module textedit.gtk.services.schedulerservice;

import textedit.services;
import textedit.utils.listener;

import gdk.Threads;

import std.stdio;
import std.exception;
import std.parallelism;

shared class Queue
{
	private shared(void delegate())[] _queue;

	bool hasNext()
	{
		return _queue.length > 0;
	}

	void delegate() next()
	{
		auto item = _queue[0];
		_queue = _queue[1 .. $];
		return item;
	}

	void push(shared(void delegate()) callback)
	{
		_queue ~= callback;
	}
}

@safe shared class Bool
{
	private bool _value = false;

	bool value() nothrow @nogc
	{
		return _value;
	}

	void value(bool value) nothrow @nogc
	{
		_value = value;
	}

	void reset() nothrow @nogc
	{
		try
		{
			synchronized (this)
			{
				_value = false;
			}
		}
		catch (Exception e)
		{}
	}
}

private shared queue = new Queue;
private shared hasThread = new Bool;

private extern(C) nothrow static int threadIdleProcess(void* data)
{
	scope(exit) hasThread.reset();
	try
	{
		for (;;)
		{
			void delegate() callback;
			synchronized (queue)
			{
				if (!queue.hasNext)
					return 0;
				callback = queue.next;
			}

			callback();
		}
	}
	catch (Exception e)
	{
		try
		{
			stderr.writeln("Exception occured:");
			stderr.writeln(e);
		}
		catch (Exception _)
		{
		}
	}
	return 0;
}

class GtkSchedulerService : ISchedulerService
{
	private ListenerContainer!() createListeners;
	private ListenerContainer!() endListeners;

	override void schedule(SchedulerThread ui, void delegate() callback)
	{
		final switch (ui)
		{
			case SchedulerThread.ui:
				executeOnUI(callback);
				break;
			case SchedulerThread.background:
				executeAsync(callback);
				break;
		}
	}

	override Listener onTaskCreated(void delegate() callback)
	{
		return createListeners.add(callback);
	}

	override Listener onTaskEnded(void delegate() callback)
	{
		return endListeners.add(callback);
	}

	void executeOnUI(void delegate() callback)
	{	
		synchronized (queue)
		{
			queue.push(callback);
		}

		synchronized (hasThread)
		{
			if (!hasThread.value)
			{
				hasThread.value = true;
				threadsAddIdle(&threadIdleProcess, null);
			}
		}
	}

	void executeAsync(void delegate() callback)
	{
		createListeners.fire();
		task({
			scope(exit) endListeners.fire();
			try
			{
				callback();
			}
			catch (Exception e)
			{
				import std.stdio : stderr;
				stderr.writeln("An exception occured:");
				e.toString((msg) {
					stderr.write(msg);
				});
				stderr.writeln();
			}
		}).executeInNewThread();
	}
}