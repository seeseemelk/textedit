module textedit.views;

import textedit.viewmodels.mainview;

/** 
 * Describes a single view or window.
 */
interface IView
{
	/** 
	 * Shows this view or window.
	 */
	void show();
}

/** 
 * Describes the main view
 */
interface IMainView : IView
{
	/**
	 * Sets the view model for this view.
	 * Params:
	 *   viewModel = The view model to use.
	 */
	void viewModel(MainViewModel viewModel);

	/**
	 * Update the memory labels.
	 */
	void updateMemory();

	/**
	 * Update the content page.
	 */
	void updateContent();
}