module textedit.utils.maybe;

/** 
 * An interface to keep track of things that might not have a value.
 */
interface Maybe(T)
{	
	/** 
	 * Checks if the `Maybe` has a value.
	 * Returns: `True` if the `Maybe` has a value, `false` if it doesn't.
	 */
	bool isPresent() const pure;

	/** 
	 * Checks if the `Maybe` has no value.
	 * Returns: `False` if the `Maybe` has a value, `true` if it doesn't.
	 */
	bool isEmpty() const pure;

	/** 
	 * Executes the callback if a value is present.
	 */
	void ifPresent(void delegate(T) callback) const;

	/** 
	 * Returns: The value of the maybe if there is one, else the passed argument.
	 */
	T orElse(T t) const;

	/**
	 * Returns: An empty maybe.
	 */
	final static Maybe empty()
	{
		return new EmptyMaybe!T;
	}

	/**
	 * Returns: An maybe with a value.
	 */
	final static Maybe of(T t)
	{
		return new ValueMaybe!T(t);
	}
}

@("empty returns empty maybe")
unittest
{
	assert(Maybe!string.empty.isPresent == false);
}

@("of returns value maybe")
unittest
{
	assert(Maybe!string.of("foo").isPresent == true);
}

private class EmptyMaybe(T) : Maybe!T
{
	override void ifPresent(void delegate(T) callback) const
	{

	}

	override bool isPresent() const pure
	{
		return false;
	}

	override bool isEmpty() const pure
	{
		return true;
	}

	override T orElse(T t) const pure
	{
		return t;
	}
}

@("EmptyMaybe is empty")
unittest
{
	auto maybe = new EmptyMaybe!string;
	assert(maybe.isPresent == false);
}

@("EmptyMaybe does not call ifPresent")
unittest
{
	auto maybe = new EmptyMaybe!string;
	bool called = false;
	maybe.ifPresent((_) {called = true;});
	assert(called == false);
}

@("EmptyMaybe returns orElse clause")
unittest
{
	auto maybe = new EmptyMaybe!string;
	assert(maybe.orElse("bar") == "bar");
}

private class ValueMaybe(T) : Maybe!T
{
	private T _value;

	this(T value)
	{
		_value = value;
	}

	override void ifPresent(void delegate(T) callback) const
	{
		callback(_value);
	}

	override bool isPresent() const pure
	{
		return true;
	}

	override bool isEmpty() const pure
	{
		return false;
	}

	override T orElse(T t) const pure
	{
		return _value;
	}
}

@("ValueMaybe is present")
unittest
{
	auto maybe = new ValueMaybe!string("foo");
	assert(maybe.isPresent == true);
}

@("ValueMaybe calls ifPresent")
unittest
{
	auto maybe = new ValueMaybe!string("foo");
	bool called = false;
	maybe.ifPresent((value) {
		assert(value == "foo");
		called = true;
	});
	assert(called == true);
}

@("ValueMaybe does not return orElse clause")
unittest
{
	auto maybe = new ValueMaybe!string("foo");
	assert(maybe.orElse("bar") == "foo");
}