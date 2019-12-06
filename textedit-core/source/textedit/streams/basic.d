module textedit.streams.basic;

import textedit.streams.core;

class SimpleDisposable : Disposable
{
	/// No-op
	override void dispose() {}

	private static shared SimpleDisposable _instance = null;
	public static instance()
	{
		if (_instance is null)
			_instance = new SimpleDisposable();
		return _instance;
	}

	@("instance returns a instance")
	unittest
	{
		assert(SimpleDisposable.instance !is null);
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

	override SimpleDisposable subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onItem(_value);
		onCompletion();
		return new SimpleDisposable;
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
	override SimpleDisposable subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail)
	{
		onCompletion();
		return new SimpleDisposable;
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