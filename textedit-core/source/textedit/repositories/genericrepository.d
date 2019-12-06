module textedit.repositories.genericrepository;

import hunt.entity;

interface IGenericRepository
{
	EntityManager getEntityManager();
}

class GenericRepository : IGenericRepository
{
	private EntityManagerFactory _factory;
	private EntityManager _manager;

	this()
	{
		auto options = new EntityOption();
		options.database.driver = "sqlite";
		options.database.host = "/home/seeseemelk/textedit.sqlite";
		options.database.database = "textedit";
		options.database.charset = "utf8mb4";

		_factory = Persistence.createEntityManagerFactory("default", options);
		_manager = _factory.createEntityManager();
	} 

	~this()
	{
		_manager.close();
		_factory.close();
	}

	override EntityManager getEntityManager()
	{
		return _manager;
	}
}