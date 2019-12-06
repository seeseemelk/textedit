module textedit.streams.core;

/**
 * Can be used to cancel a flux.
 */
interface Disposable
{
	/**
	 * Cancels a flux.
	 */
	void dispose();
}

/**
 * Describes an interface that might contain a series of elements.
 */
interface Flux(T)
{
	/**
	 * Subscribes to a stream of values that will be published by this flux.
	 * Params:
	 *   onItem = A delegate that will consume the output of the flux.
	 *   onCompletion = A delegate that is called once the flux has been completed.
	 *   onFail = A delegate that is called if an error occured in the flux.
	 */
	void subscribe(void delegate(T) onItem, void delegate() onCompletion, void delegate() onFail);

	static Flux!T of(T)(T[] range)
	{
		import textedit.streams.basic : RangeFlux;
		return new RangeFlux!T(range);
	}
}

/**
 * A Mono is a Stream that will contain at most one item.
 */
interface Mono(T) : Flux!(T)
{
	static Mono!T of(T)(T value)
	{
		import textedit.streams.basic : ValueMono;
		return new ValueMono!T(value);
	}

	static Mono!T empty(T)()
	{
		import textedit.streams.basic : EmptyMono;
		return new EmptyMono!T;
	}
}