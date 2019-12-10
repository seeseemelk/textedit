module textedit.services.dialogservice;

import textedit.utils.maybe;

/**
 * A service that can display dialogs to the user.
 */
@safe interface IDialogService
{
	/**
	 * Show an open file dialog.
	 * Returns: A mono possibly containing a selected file.
	 */
	Maybe!string showOpenFileDialog();
}