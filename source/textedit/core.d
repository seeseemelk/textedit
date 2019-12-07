module textedit.core;

import textedit.services;
import textedit.viewmodels;
import textedit.views;

import poodinis;

/** 
 * Runs the main application
 */
void bootTextedit(void delegate(shared DependencyContainer) containerRegisterCallback)
{
	auto dependencies = new shared DependencyContainer();
	
	containerRegisterCallback(dependencies);
	
	registerServices(dependencies);
	registerViewModels(dependencies);

	dependencies.resolve!MainViewModel;
}

private void registerServices(shared DependencyContainer container)
{
	container.register!MemoryService;
}

private void registerViewModels(shared DependencyContainer container)
{
	container.register!MainViewModel;
}