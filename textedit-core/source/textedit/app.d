module textedit.app;

import textedit.services;
import textedit.viewmodels;
import textedit.views;
import textedit.repositories;

import poodinis;

/** 
 * Runs the main application
 */
void runTextedit(void delegate(shared DependencyContainer) containerRegisterCallback)
{
	auto dependencies = new shared DependencyContainer();
	
	containerRegisterCallback(dependencies);
	
	registerServices(dependencies);
	registerViewModels(dependencies);
	registerRepositories(dependencies);

	dependencies.resolve!MainViewModel;
}

private void registerServices(shared DependencyContainer container)
{
	container.register!(IMemoryService, MemoryService);
	container.register!(IDocumentService, DocumentService);
}

private void registerViewModels(shared DependencyContainer container)
{
	container.register!MainViewModel;
}

private void registerRepositories(shared DependencyContainer container)
{
	container.register!RepositoryFactory;
	container.register!(IRecentFilesRepository, RecentFilesRepository);
}