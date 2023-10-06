# Dragon Age Origins DPI Wrapper script for use with dgVoodoo2

I wrote a batch file. Can't recommend it.

Wraps the launching of the DAOrigins executable so we can set the registry value to ensure it is run in compatibility mode `System (enhanced)` (which is "reset" every time it closes, so must be set every time we open it) and adjusts the DPI to an appropriate value so that the mouse behaves correctly when using dgVoodoo2 to force the resolution of Dragon Age Origins. Note that the problem you will see if this isn't working correctly is the cursor either being trapped in a box in the top-left of the screen, or the cursor being free to move *way* offscreen to the right or the bottom of the screen.

# Overview

This script essentially does nothing more than:

- Set Dragon Age Origins to launch in the `System (enhanced)` mode as seen in `Properties > Compatibility > Change high DPI settings > High DPI scaling override` dropdown

- Figure out what percent of the Dragon Age Origins resolution the specified dgVoodoo resolution is

- Get the current `Scale` percentage as seen in `System > Display > Scale`

- Set the `Scale` percentage as seen in `System > Display > Scale` to that value 

- Run `DAOrigins.exe`

- When `DAOrigins.exe` closes, it resets the `Scale` percentage as seen in `System > Display > Scale` to the previous value

Can this all be done manually? Yes, of course. Is it fiddly and irritating to do every time you want to launch the game? ...I suppose that's up to you, but you are here, after all.

## How to use

- Before anything else, get a LAA (large address aware) copy of the Dragon Age Origins executable. You can patch it yourself with the LAA tool available online unless you have the Steam version, which is encrypted. The guide [here](https://steamcommunity.com/sharedfiles/filedetails/?id=233222451) explains the process of patching the executable (and provides a patched copy of that executable for those who cannot or do not wish to patch it themselves. This should replace your normal `DAOrigins.exe`, though I of course suggest that you back up your original file before patching or replacing it. This step may or may not be necessary, but I haven't tested anything with the unpatched executable.

- Next, go get [dgVoodoo2](http://dege.freeweb.hu/dgVoodoo2/dgVoodoo2/) and ["install"](http://dege.freeweb.hu/dgVoodoo2/QuickGuide/) it next to (in the same folder as) your `DAOrigins.exe`. Run `dgVoodooCpl.exe` and select your preferred resolution for 3D elements in the DirectX tab. Save the configuration (`dgVoodoo.conf`) in `./` instead of the default location.

- Note that if you are using [ReShade](https://reshade.me/), you will need to uninstall it from the `DAOrigins.exe` executable and then re-apply it targeting DX10+. Incidentally, I recommend ReShade for anti-aliasing if nothing else (though remember to disable anti-aliasing in the Dragon Age Origins setting if you go that route). 

- Then, go get [SetDPI.exe](https://github.com/tempoz/SetDPI/releases/tag/v1.0.1). You can build it yourself following the directions in the `README.md` or just download the `SetDPI.exe` if you trust me ;)  Copy the SetDPI.exe executable next to (in the same folder as) your `DAOrigins.exe` executable.

- Copy the `wrapper.bat` file in this repository next to (in the same folder as) your `DAOrigins.exe`.

- Run `DAOriginsConfig.exe` and select the resolution you want the UI to display at (smaller resolutions mean a bigger UI). Remember that whatever resolution you select must match the aspect ratio of the resolution you selected in the dgVoodoo step. Don't forget to save the setting before closing.

- (Optional) To avoid an irritating dialog box on game close, you can [disable the Program Compatibility Assistant](https://www.isunshare.com/computer/why-and-how-to-disable-program-compatibility-assistant-service.html). If this page disappears, there are instructions included in the second comment block in the `wrapper.bat` file.

- Double-click the `wrapper.bat` sitting next to (in the same folder as) your `DAOrigins.exe`, and it should launch Dragon Age Origins executable.

## Limitations

- If you want to run Dragon Age Origins on a monitor that is not your primary one, you will need to change the `monitor_number` to the number of the monitor in question in the `wrapper.bat` file.

- Changing the game's resolution in-game will not behave correctly, though if you then close the game and re-open it, it should work again.

- As mentioned above, the two resolutions must be the same aspect ratio and even still only some scaling factors are supported. If you hit this, you'll see an error message explaining the supported scaling factors and what yours was.

- If you want to launch DAOrigins through the official launcher (the one with the menu and then the `Play` button at the bottom) or through Steam, they won't run the wrapper. You'll need to:

  - Move (rename) the DAOrigins executable to a new name in the same directory (I use `DAOriginsActual.exe`, but any name works. I recommend no spaces or non-dot special characters to save yourself potential headaches, though).
  
  - Make a new `DAOrigins.exe` that runs this wrapper (I made [tempoz/Launch](https://github.com/tempoz/Launch) for this exact purpose)
  
  - Change the `dao_executable` var in the wrapper to the new name of the Dragon Age Origins executable
