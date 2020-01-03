module textedit.repositories.globalrepository;

public import microrm;

/// A repository that can be used to store 
class GlobalRepository
{
	private MDatabase _db;

	this()
	{
		this(".textedit.db");
	}

	this(string dbPath)
	{
		_db = new MDatabase(dbPath);
	}

	/// Closes the database.
	void close()
	{
		_db.close();
	}

	/// Executes a query on the database.
	MDatabase db()
	{
		return _db;
	}

	@("execute calls delegate with database")
	unittest
	{
		withTestDb((repo)
		{
			assert(repo.db !is null);
		});
	}
}

version (unittest) void withTestDb(void delegate(GlobalRepository) callback)
{
	import std.file : tempDir;
	import std.path : buildPath;
	import std.random : uniform;
	import std.conv : to;
	const num = uniform(0, 65_536*1024);
	const path = tempDir.buildPath("textedit-test-global-" ~ num.to!string ~ ".db");
	auto repository = new GlobalRepository(path);
	callback(repository);
	repository.close();
}