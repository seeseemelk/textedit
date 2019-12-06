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

}