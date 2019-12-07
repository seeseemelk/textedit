module textedit.streams.maybe;

interface Maybe(T)
{
	void ifPresent(void delegate(T) callback);
	
	bool isPresent();
	
	bool isEmpty()
	{
		return !isPresent();
	}

	T orElse(T t);

	static Maybe!T empty()
	{
		return new EmptyMaybe!T;
	}

	static Maybe!T of(T t)
	{
		return new ValueMaybe(t);
	}
}

private class EmptyMaybe(T) : Maybe!T
{
	override void ifPresent(void delegate(T) callback)
	{

	}

	override bool isPresent()
	{
		return false;
	}

	override T orElse(T t)
	{
		return t;
	}
}

private class ValueMaybe(T) : Maybe!T
{
	private T _value;

	this(T value)
	{
		_value = value;
	}

	override void ifPresent(void delegate(T) callback)
	{
		callback(value);
	}

	override bool isPresent()
	{
		return true;
	}

	override T orElse(T t)
	{
		return _value;
	}
}