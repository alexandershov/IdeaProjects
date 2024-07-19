## Unreal Engine

### Install
You need to download Epic Games Launcher and download Unreal Engine 5 (UE5) from there.


UE5 is ~15GB download (150GB with debug symbols). You'll also need Xcode.


### Tutorial
I tried following the tutorial "Your first hour in Unreal Engine 5": https://dev.epicgames.com/community/learning/courses/ZpX/your-first-hour-in-unreal-engine-5-0/
It's messed up, because a current version is 5.4 and tutorial uses assets from Online Learning Kit that's 
requires version <= 5.1

Right mouse button + WASD moves the viewport in the editor. 
Right mouse button + QE moves the viewport down/up.

Choose "unlit" in the top left corner, that helps to see the scene if have no lighting.
Select an item (in the right column) and press "F" to respectfully focus on the item.

Press "Alt" and drag on axis to duplicate selected item(s) and move duplicate on this axis.

"Unlit" works only for an editor, in game you'll have no lighting. 
So change to "lit" and add directional light.
Directional light is essentially a sun-like light.
You can rotate it with the usual "Select and Rotate"

Unreal Engine is a great way to really heat up your macbook. 
Disable Realtime with Cmd-R, it makes things better.

You can change object parameters even when you're playing the level. Press "Shift-F1" and use cursor as usual.

If interface pesters you with "unbuilt lighting", then use "Build" -> "Build Lighting Only" in a menu.

You can project settings with "Edit" -> "Project settings", "Cmd"-comma are not for the project settings, but
for the editor settings.


### Blueprint
Blueprint is a visual programming language. 
Essentially, you build a graph of nodes. Node can be event (e.g. collision) or action (e.g. "Print String")

For collision you can use event ActorBeginOverlap, for printing you can use action "Print String" 

You can blueprint to existing items: "Add" -> "New blueprint script component" and then edit blueprint.

You can see logs in "Output Logs" tab, it's in the bottom left corner of the screen.


