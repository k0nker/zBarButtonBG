Whenever you run a command in the terminal, pipe the output to a file, output.txt, that you can read from. Make sure to overwrite each time so that it doesn't grow too big. There is a bug in the current version of Copilot that causes it to not read the output of commands correctly. This workaround allows you to read the output from the temporary file instead. 

All strings a user sees should be localized, be sure to add them to all localization files. Also, check when I make changes to add to localization files too.

Don't make extra files to explain changes. No summary documents or anything like that. Not helpful. You can summarize in the chat, but don't make a new file for it.

If we are referencing another addon or library and using something from there or mimicing them, don't reference them in the code comments. Add a single line at the top of our main lua file and just add that as a credits reference. No need to reference them throughout the code.

When possible, use the Defaults.lua file to set default values for new settings. Don't hardcode them in the main code. If the user can also change it, use the users choice, and if the users choice doesn't exist use the default from Defaults.lua.

When making changes, try to keep the style consistent with the existing codebase unless there is a good reason to change it.