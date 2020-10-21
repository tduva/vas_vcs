# Video Autosplitter for Vice City Stories

This is a profile for the LiveSplit [VideoAutoSplit](https://github.com/ROMaster2/LiveSplit.VideoAutoSplit) component. The component is not entirely finished, so it has some quirks and might not work for everybody.

The image recognition is based on stream screenshots of Joshimuz' VCS runs. I don't know how well the same images/settings will work for other setups.

## Usage

Install the [VideoAutoSplit](https://github.com/ROMaster2/LiveSplit.VideoAutoSplit) component in LiveSplit and follow the instructions. The Scan Region must cover the entire game. It is made based on width 1600 and height 900.

The preview should show the game and the selected region. If the preview is not shown you can try restarting LiveSplit or try another video capture device. Sometimes opening/closing the Video Autosplitter settings can cause the capture to break, so if it doesn't split, try to restart LiveSplit (make sure to save the layout after changing settings before restarting though).

The Autosplitter is supposed to split the following:

* Mission Passed
* Attack Passed (for Assets)
* Title/Loading screen (for Save&Quit)

This script has several ways to combine multiple splits into one split (e.g. for duping or just combining several mission passes into one). The script will look at the current split name and determine a number from it and then only split when it has reached that number of theoretical splits. For example `OBWAT? x3` will only split after 3 Mission Pass screens (or other screens where it would split).

* `[<number>]` anywhere (e.g. `OBWAT? [3]` = 3) sets the number and causes all other formats to be ignored
* Other formats
   * `x<number>` (only small x) anywhere (e.g. `OBWAT? x3` = 3 or `Mission Name (x4)` = 4)
   * `<number>` at the very beginning of a split name, possibly after Subsplits formatting (e.g. `2 Asset Takeovers` = 2)
   * `+` to add parts together, with each part counting as 1 or the number specified (e.g. `HTH x4 + Dupe` = 4+1 = 5 or `Mission1 + Mission2` = 1+1 = 2)

Theoretically there are settings to enable/disable each type of format, however the settings in the VideoAutoSplit component don't seem to properly work, so it's best to just ignore them.

*Note:* It will not split in the first 10 seconds of the run to prevent the title screen to split when starting the run. It will also not recognize a split more than once within 10 seconds (this is to prevent double-splitting when a Mission Passed fades/in out and just generally makes it easier because it simply splits the first time it recognizes a screen and then waits a bit until it should have disappeard).
