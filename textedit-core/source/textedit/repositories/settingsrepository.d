module textedit.repositories.settingsrepository;

import textedit.repositories.genericrepository;
import textedit.models.setting;

import hunt.entity;

interface ISettingsRepository
{
	Setting findSetting(string name);
}

class SettingsRepository : ISettingsRepository
{
	private IGenericRepository _repository;

	override Setting findSetting(string name)
	{
		auto manager = _repository.getEntityManager();
		return manager.find!Setting(name);
	}
}