openfl-gpg
=======

OpenFL extension for "Google Play Games" on Android.

###Main Features

* Achievements (complete, send progress, reveal/unhide, display achievements screen).
* Scoreboards (submit scores, display scoreboard).
* Login / Init.
* Cloud Storage support (for storing progress / scores on google cloud - up to 4KB of data).
* Callback events for onCloudComplete (read from cloud) and onCloudConflict (version conflict on cloud).
* Automatic conflict resolution (by keeping the newest version by default). You can change that by implementing the onCloudConflict method.
* XML Parser to load the ID's from Google's XML resources file.

###Simple use Example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method passing the main stage as parameter.
		// the second parameter is to enable cloud storage service.
		GooglePlayGames.init(mainStage,true);
	}
	
	function login() {
		GooglePlayGames.login(); // to force a login request to the user.
	}

	function displayScoreboard() {
		GooglePlayGames.showSocoreBoard("your-scoreboard-id"); // to open one specific scoreboard.
		//GooglePlayGames.displayAllScoreboards(); // to show all scoreboards.
	}
	
	function displayAchievements() {
		GooglePlayGames.displayAchievements(); // to display the achievements.
	}

	function submitScoresAndAchievements() {
		GooglePlayGames.setSocre("scoreboard-id",234); // to set 234 points on scoreboard.
		GooglePlayGames.reveal("achievement-id"); // to make one achievement visible
		GooglePlayGames.setSteps("achievement-id",30); // to set one achievement to progress to 30.
		GooglePlayGames.increment("achievement-id"); // to increment the progress of one achievement.
		GooglePlayGames.unlock("achievement-id"); // to unlock / complete one achievement.
	}
	
}

```

###Cloud Storage use Example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class SomeClass {

	function new() {
		GooglePlayGames.onCloudComplete=onCloudComplete;
		GooglePlayGames.onCloudConflict=onCloudConflict;
	}
	
	function saveToCloud(id:Int, data:String) {
		GooglePlayGames.cloudSet(id,data);
	}
	
	function loadFromCloud(id:Int) {
		GooglePlayGames.cloudGet(id);
	}
	
	function onCloudComplete(id:Int, data:String) {
		trace("Data on record: "+id+" is: "+data);
	}

	function onCloudConflict(id:Int, localValue:String, serverValue:String) {
		trace("Conflict on record: "+id);
	}
	
}

```

###XML Resources parsing example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method passing the main stage as parameter.
		// the second parameter is to enable cloud storage service.
		GooglePlayGames.init(mainStage,true);
		
		// Google allows you to download an XML file with you IDs related to some alias name.
		// It's a good practice to match your alias from google play games with your alias on game center, to simplify your code.
		var xmlText='......
			     <resources>
				<string name="complete stage 1">CgkI-7SKzbALA2IQAQ</string>
				<string name="kill 100 enemies">CgkI-7SKzbALA2IQBw</string>
				<string name="complete stage 2">CgkI-7SKzbALA2IQAg</string>
			     </resources>';
			     
		GooglePlayGames.loadResourcesFromXML(xmlText);
	}

	function doSomething() {	
		GooglePlayGames.reveal( GooglePlayGames.getID("kill 100 enemies") ); // to use an alias name instead of the ugly ID
	}

}

```

###How to Install

To install this library, you can simply get the library from haxelib like this:
```bash
haxelib install openfl-gpg
```

Also, you'll need to download the google-play-services_lib from your Android SDK Manager. To do that, you need to execute the android tool from:
```bash
$ANDROID_SDK/tools/android
```

Then select *Google Play Services* under the "Extras" section.

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="openfl-gpg" />
<setenv name="GOOGLE_PLAY_GAMES_ID" value="32180581421" /> <!-- REPLACE THIS WITH YOUR GOOGLE PLAY GAMES ID! -->
```

###Disclaimer

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

###License

http://www.gnu.org/licenses/lgpl.html

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.
  
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
  
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
  

WebSite: https://github.com/fbricker/openfl-webview | Author: Federico Bricker | Copyright (c) 2013 SempaiGames (http://www.sempaigames.com)
