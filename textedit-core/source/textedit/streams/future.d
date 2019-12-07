module textedit.streams.future;

interface Future(T)
{
	T get();
}