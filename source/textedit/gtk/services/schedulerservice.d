module textedit.gtk.services.schedulerservice;

import textedit.services;
import textedit.streams.future;

import gdk.Threads;

import std.stdio;
import std.exception;
import std.parallelism;
import core.sync.event;

shared class Queue
{
	private void delegate()[] _queue;

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

	void push(void delegate() callback)
	{
		_queue ~= callback;
	}
}

shared class Bool
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
		void delegate() callback;
		synchronized (queue)
		{
			if (!queue.hasNext)
				return 0;
			callback = queue.next;
		}

		callback();
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

class SchedulerService
{
	this()
	{

	}

	Future!T executeOnUI(T)(T delegate() callback)
	{
		auto future = new TaskFuture!T;
		
		synchronized (queue)
		{
			queue.push(() {
				auto result = callback();
				future.set(result);
			});
		}
		synchronized (hasThread)
		{
			if (!hasThread.value)
			{
				hasThread.value = true;
				threadsAddIdle(&threadIdleProcess, null);
			}
		}

		return future;
	}

	void executeAsync(void delegate() callback)
	{
		task(callback).executeInNewThread();
	}
}

private class TaskFuture(T) : Future!T
{
	private T _value;
	private Event _event;

	this()
	{
		_event.initialize(false, false);
	}

	void set(T value)
	{
		_value = value;
		_event.set();
	}

	T get()
	{
		_event.wait();
		return _value;
	}
}