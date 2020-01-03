module textedit.repositories.recentfilesrepository;

import textedit.repositories.globalrepository;

import std.array;

private struct RecentFile
{
	string path;
}

class RecentFilesRepository
{
	private GlobalRepository _repository;

	this(GlobalRepository repository)
	{
		_repository = repository;
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
		withTestDb((db) {
			auto repository = new RecentFilesRepository(db);
			repository.addRecentFile("file-a");
			auto files = repository.getRecentFiles();
			assert(files.length == 1);
			assert(files[0].path == "file-a");
		});
	}
}