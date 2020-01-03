module textedit.repositories.recentfilesrepository;

import textedit.repositories.repository;

import std.array;

/// Represents a file in the recent files list.
struct RecentFile
{
	/// The path to the file.
	string path;
}

interface IRecentFilesRepository
{
	/// Adds a recent file.
	void addRecentFile(string path);

	/// Gets a list of all recent files.
	RecentFile[] getRecentFiles();
}

class RecentFilesRepository : IRecentFilesRepository
{
	private Repository _repository;

	this(RepositoryFactory factory)
	{
		_repository = factory.globalRepository();
		_repository.db.run(buildSchema!RecentFile);
	}

	void addRecentFile(string path)
	{
		_repository.db.insert(RecentFile(path));
	}

	RecentFile[] getRecentFiles()
	{
		return _repository.db.select!RecentFile.run().array();
	}

	@("recent files can be added and retrieved")
	unittest
	{
		scope repository = new RecentFilesRepository(new TestRepositoryFactory());
		repository.addRecentFile("file-a");
		auto files = repository.getRecentFiles();
		assert(files.length == 1);
		assert(files[0].path == "file-a");
	}
}