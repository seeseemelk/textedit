import std.stdio;

void hello()
{
	writeln("Hello");
}

@("cool")
unittest
{
	writeln("Cool");
}
