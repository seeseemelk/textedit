module textedit.streams.basic;

import textedit.streams.core;
import textedit.streams.utils;

class NoopDisposable : Disposable
{
	/// No-op
	override void dispose() {}

	private static shared NoopDisposable _instance = null;
	public static instance()
	{
		if (_instance is null)
			_instance = new NoopDisposable();
		return _instance;
	}

	@("instance returns a instance")
	unittest
	{
		assert(NoopDisposable.instance !is null);
	}
}

class SimpleDisposable : Disposable
{
	private bool _disposed = false;
	
	bool disposed()
	{
		return _disposed;
	}

	@("disposed for undisposed disposable is false")
	unittest
	{
		auto disposable = new SimpleDisposable;
		assert(disposable.disposed == false);
	}

	override void dispose()
	{
		_disposed = true;
	}

	@("disposed for disposed disposable is true")
	unittest
	{
		auto disposable = new SimpleDisposable;
		disposable.dispose();
		assert(disposable.disposed == true);
	}
}

class ValueMono(T) : Mono!(T)
{
	private T _value;

	this(T value)
	{
		_value = value;
	}

	T value()
	{
		return _value;
	}

	override void subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onItem(_value);
		onCompletion();
	}
}

@("value returns content of mono")
static unittest
{
	auto mono = new ValueMono!string("abc");
	assert(mono.value == "abc");
}

@("subscribe on ValueMono calls callbacks with value")
unittest
{
	auto mono = new ValueMono!string("abc");
	string valueFromCallback;
	bool completionCalled = false;
	bool failureCalled = false;

	mono.subscribe((value) {
		valueFromCallback = value;
		assert(completionCalled == false);
	}, () {
		completionCalled = true;
	}, () {
		failureCalled = true;
	});

	assert(valueFromCallback == "abc");
	assert(completionCalled == true);
	assert(failureCalled == false);
}

class EmptyMono(T) : Mono!(T)
{
	override void subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onCompletion();
	}
}

@("subscribe on EmptyMono does not call consumer")
unittest
{
	auto mono = new EmptyMono!string;

	bool onItem = false;
	bool onCompletion = false;
	bool onFail = false;

	mono.subscribe((value) {
		onItem = true;
	}, () {
		onCompletion = true;
	}, () {
		onFail = true;
	});

	assert(onItem == false);
	assert(onCompletion == true);
	assert(onFail == false);
}

class RangeFlux(T) : Flux!T
{
	private T[] _values;

	this(T[] values)
	{
		_values = values;
	}

	override void subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		foreach (value; _values)
		{
			onItem(value);
		}
		onCompletion();
	}
}

@("subscribe for range flux will call for each value in range")
unittest
{
	auto flux = new RangeFlux!int([1, 2, 3]);
	auto onCompletion = false;
	auto onFail = false;

	auto nextNumber = 1;
	flux.subscribe((num) {
		assert(num == nextNumber);
		assert(onCompletion == false);
		nextNumber++;
	}, () {
		onCompletion = true;
	}, () {
		onFail = true;
	});

	assert(onCompletion == true);
	assert(onFail == false);
}

class PublishFlux(T) : Flux!T
{
	private T[] _queue;
	private bool _completed = false;
	private bool _failed = false;
	
	private void delegate(T) _onItem;
	private void delegate() _onCompletion;
	private void delegate() _onFail;

	this()
	{
		_onCompletion = () {};
		_onFail = () {};
		_onItem = (item) {
			_queue ~= item;
		};
	}

	void publish(T item)
	{
		if (!_completed && !_failed)
			_onItem(item);
	}

	void complete()
	{
		if (_failed || _completed)
			return;
		_onCompletion();
		_completed = true;
	}

	void fail()
	{
		if (_failed || _completed)
			return;
		_onFail();
		_failed = true;
	}

	override void subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		_onItem = onItem;
		_onCompletion = onCompletion;
		_onFail = onFail;

		foreach (item; _queue)
		{
			onItem(item);
		}

		if (_completed)
			onCompletion();
		if (_failed)
			onFail();
	}
}

@("publishItem published item")
unittest
{
	auto flux = new PublishFlux!string;
	string item;
	flux.subscribeItem!string((value) {
		item = value;
	});

	flux.publish("hello");
	assert(item == "hello", "Flux did not publish item");
}

@("complete completes flux")
unittest
{
	auto flux = new PublishFlux!string;
	bool onItem = false;
	bool onComplete = false;
	bool onFail = false;

	flux.subscribe((value) {
		onItem = true;
	}, () {
		onComplete = true;
	}, () {
		onFail = true;
	});

	flux.complete();
	flux.fail();
	flux.publish("");
	assert(onComplete == true, "Flux was not completed");
	assert(onItem == false, "Flux published item after completion");
	assert(onFail == false, "Flux published fail after completion");
}

@("fail completes flux")
unittest
{
	auto flux = new PublishFlux!string;
	bool onItem = false;
	bool onComplete = false;
	bool onFail = false;

	flux.subscribe((value) {
		onItem = true;
	}, () {
		onComplete = true;
	}, () {
		onFail = true;
	});

	flux.fail();
	flux.complete();
	flux.publish("");
	assert(onComplete == false, "Flux published complete after failure");
	assert(onItem == false, "Flux published item after failure");
	assert(onFail == true, "Flux did not fail");
}