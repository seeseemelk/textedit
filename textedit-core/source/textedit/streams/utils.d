module textedit.streams.utils;

import textedit.streams;

void subscribeItem(T)(Flux!T flux, void delegate(T) onItem)
{
	flux.subscribe(onItem, () {}, () {});
}

@("subscribe calls delegate with item")
unittest
{
	auto mono = Mono!string.of("abc");
	string valueFromCallback;
	mono.subscribeItem!string((value) {
		valueFromCallback = value;
	});
	assert(valueFromCallback == "abc");
}

Flux!T filter(T)(Flux!T flux, bool delegate(T) predicate)
{
	auto newFlux = new PublishFlux!T;
	flux.subscribe((value) {
		if (predicate(value))
		{
			newFlux.publish(value);
		}
	}, &newFlux.complete, &newFlux.fail);
	return newFlux;
}

@("filter filters a flux")
unittest
{
	auto flux = Flux!int.of([1, 2, 3]);
	int[] output;
	flux
		.filter!int(n => n != 2)
		.subscribeItem!int((n) {output ~= n;});
	
	assert(output == [1, 3]);
}

Flux!B map(A, B)(Flux!A flux, B delegate(A) mapper)
{
	auto newFlux = new PublishFlux!B;
	flux.subscribe((value) {
		newFlux.publish(mapper(value));
	}, &newFlux.complete, &newFlux.fail);
	return newFlux;
}

@("map maps a flux")
unittest
{
	auto flux = Flux!int.of([1, 2, 3]);
	int[] output;
	flux
		.map!(int, int)(n => n * 10)
		.subscribeItem!int((n) {output ~= n;});
	
	assert(output == [10, 20, 30]);
}
