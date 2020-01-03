module textedit.repositories.repository;

public import microrm;

/// A repository that can be used to store 
struct Repository
{
	private MDatabase _db;

	this() @disable;

	this(string dbPath)
	{
		_db = new MDatabase(dbPath);
	}

	~this()
	{
		_db.close();
	}

	MDatabase db()
	{
		return _db;
	}

	@("execute calls delegate with database")
	unittest
	{
		scope repo = new TestRepositoryFactory().globalRepository();
		assert(repo.db() !is null);
	}
}

class RepositoryFactory
{
	Repository globalRepository()
	{
		return Repository(".textedit.db");
	}
}

version (unittest)
{
	import std.file : tempDir;
	import std.path : buildPath;
	import std.random : uniform;
	import std.conv : to;

	class TestRepositoryFactory : RepositoryFactory
	{
		override Repository globalRepository()
		{
			const num = uniform(0, 65_536*1024);
			const path = tempDir.buildPath("textedit-test-global-" ~ num.to!string ~ ".db");
			return Repository(path);
		}
	}
}