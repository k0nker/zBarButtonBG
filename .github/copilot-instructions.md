All strings a user sees should be localized, add them to at least the enUS.lua. Also, check when I make changes to add to localization files too.

Don't make extra files to explain changes. No summary documents or anything like that. Not helpful. You can summarize in the chat, but don't make a new file for it.

If we are referencing another addon or library and using something from there or mimicing them, don't reference them in the code comments. Add a single line at the top of our main lua file and just add that as a credits reference. No need to reference them throughout the code.

When possible, use the Defaults.lua file to set default values for new settings. Don't hardcode them in the main code. If the user can also change it, use the users choice, and if the users choice doesn't exist use the default from Defaults.lua.

When making changes, try to keep the style consistent with the existing codebase unless there is a good reason to change it. For example, we are trying to stay modularized, so avoid making big monolithic functions that do a lot of different things. Break them up into smaller helper functions when possible. We already have a lot of helper functions and code, so reference what we already have in other files when possible instead of making new code that does the same thing.

When applying patches, make sure to only include the relevant changes. Avoid including unrelated formatting changes or whitespace modifications that can clutter the diff and make it harder to review the actual changes. Also ensure that you are not deleting code or comments that are not explicitly part of the change request.