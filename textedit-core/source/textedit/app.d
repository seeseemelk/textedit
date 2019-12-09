module textedit.app;

import textedit.services;
import textedit.viewmodels;
import textedit.views;

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

	dependencies.resolve!MainViewModel;
}

private void registerServices(shared DependencyContainer container)
{
	container.register!NavigationService;
	container.register!(IMemoryService, MemoryService);
}

private void registerViewModels(shared DependencyContainer container)
{
	container.register!MainViewModel;
}