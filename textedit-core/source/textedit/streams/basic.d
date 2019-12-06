module textedit.streams.basic;

import textedit.streams.core;

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

	override NoopDisposable subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onItem(_value);
		onCompletion();
		return new NoopDisposable;
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

@("subscribe on ValueMono returns disposable")
unittest
{
	auto mono = new ValueMono!string("abc");
	auto disposable = mono.subscribe((value) {}, () {}, () {});
	assert(disposable !is null);
}

class EmptyMono(T) : Mono!(T)
{
	override NoopDisposable subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onCompletion();
		return new NoopDisposable;
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

	override SimpleDisposable subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		auto disposable = new SimpleDisposable;
		foreach (value; _values)
		{
			onItem(value);
		}
		onCompletion();
		return disposable;
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

@("dispose for range flux will cancel flux")
unittest
{
	auto flux = new RangeFlux!int([1, 2, 3]);
	auto onCompletion = false;
	auto onFail = false;

	int callCount = 0;
	Disposable disposable;
	disposable = flux.subscribe((num) {
		disposable.dispose();
		callCount++;
	}, () {
		onCompletion = false;
	}, () {
		onFail = true;
	});

	assert(callCount == 1);
	assert(onCompletion == false);
	assert(onFail == false);
}