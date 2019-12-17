module textedit.services.dialogservice;

import textedit.utils.maybe;

/**
 * A service that can display dialogs to the user.
 */
interface IDialogService
{
	/**
	 * Show an open file dialog.
	 * Returns: Maybe the selected file.
	 */
	Maybe!string showOpenFileDialog();

	/**
	 * Shows a save file dialog.
	 * Returns: Maybe a path to save a file to.
	 */
	Maybe!string showSaveFileDialog();

	/**
	 * Show a confirmation dialog.
	 * Returns: Maybe a boolean containing the result of the confirmation dialog.
	 */
	Maybe!bool showConfirmationDialog(string message);
}