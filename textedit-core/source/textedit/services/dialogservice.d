module textedit.services.dialogservice;

import textedit.streams;

/**
 * A service that can display dialogs to the user.
 */
interface IDialogService
{
	/**
	 * Show an open file dialog.
	 * Returns: A mono possibly containing a selected file.
	 */
	Mono!string showOpenFileDialog();
}