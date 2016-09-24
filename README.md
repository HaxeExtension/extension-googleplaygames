#extension-googleplaygames

OpenFL extension for "Google Play Games" on Android.

###Main Features

* Achievements (complete, send progress, reveal/unhide, display achievements screen).
* Scoreboards (submit scores, display scoreboard).
* Login / Init.
* Cloud Storage support (for storing progress / scores on google cloud - up to 4KB of data).
* Callback events for onCloudComplete (read from cloud) and onCloudConflict (version conflict on cloud).
* Callback event for login / init
* Automatic conflict resolution (by keeping the newest version by default). You can change that by implementing the onCloudConflict method.
* XML Parser to load the ID's from Google's XML resources file.

###Simple use Example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method.
		// the boolean parameter is to enable cloud storage service. Note that google and will
		// prompt for that permission to the user the first time.
		GooglePlayGames.init(true);
		// IMPORTANT: If you call init(true) you're enabling Saved Games API, so remember to enable
		// that feature on your google play games console to avoid Runtime Errors.
		// If you don't want to use Saved Games API, just calal GooglePlayGames.init(false);
	}
	
	function login() {
		// to force a login request to the user. This is optional and you may not even call this function
		// at all. Call this just if you want to force the user to login (instead of waiting the user to
		// call displayAchievements or displayScoreboard ...
		GooglePlayGames.login();
	}

	function displayScoreboard() {
		GooglePlayGames.displayScoreboard("your-scoreboard-id"); // to open one specific scoreboard.
		//GooglePlayGames.displayAllScoreboards(); // to show all scoreboards.
	}
	
	function displayAchievements() {
		GooglePlayGames.displayAchievements(); // to display the achievements.
	}

	function submitScoresAndAchievements() {
		GooglePlayGames.setScore("scoreboard-id",234); // to set 234 points on scoreboard (Int data type).
		GooglePlayGames.setScore64("scoreboard-id",234); // to set 234 points on scoreboard (Long data type).
		GooglePlayGames.reveal("achievement-id"); // to make one achievement visible
		GooglePlayGames.setSteps("achievement-id",30); // to set one achievement to progress to 30.
		GooglePlayGames.increment("achievement-id",1); // to increment the progress of one achievement in one.
		GooglePlayGames.unlock("achievement-id"); // to unlock / complete one achievement.

		// Please note that all this functions returns false if the user is not logged into the game.
		// In that case you may want to call "GooglePlayGames.login();"
	}
	
}

```

###SavedGames API Example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class SomeClass {

	function new() {
		GooglePlayGames.onLoadGameComplete=onLoadGameComplete;
		GooglePlayGames.onLoadGameConflict=onLoadGameConflict;
	}
	
	function closeGame(){
		GooglePlayGames.discardAndClose();
	}

	function saveGame(data:String, comment:String="autosave") {
		// Note that google requires that you first open a game before you can modify / save it.
		// So, this will save on last game opened.
		GooglePlayGames.commitAndCloseGame(data,comment);
	}
	
	function loadGame(name:String) {
		GooglePlayGames.loadSavedGame(name);
	}
	
	function onLoadGameComplete(name:String, data:String) {
		trace("Data on saved game: "+name+" is: "+data);
	}

	function onLoadGameConflict(name:String, data:String, conflictData:String) {
		trace("Conflict on saved game: "+name);
	}
	
}

```


###Login event example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method.
		// the boolean parameter is to enable cloud storage service. Note that google and will
		// prompt for that permission to the user the first time.
		// Set up the login result event callback first, always before init()
		GooglePlayGames.onLoginResult = loginCallback;
		GooglePlayGames.init(true);
		// IMPORTANT: If you call init(true) you're enabling Saved Games API, so remember to enable
		// that feature on your google play games console to avoid Runtime Errors.
		// If you don't want to use Saved Games API, just calal GooglePlayGames.init(false);
	}
	
	function login() {
		// to force a login request to the user. This is optional and you may not even call this function
		// at all. Call this just if you want to force the user to login (instead of waiting the user to
		// call displayAchievements or displayScoreboard ...
		GooglePlayGames.login();
	}
	
	function loginCallback(result:Int):Void {
		// The possible returned values are:
		// -1 = failed login
		//  0 = trying to log in
		//  1 = logged in
		// this event is fired several times on differents situations, results vary and must be tested
		// and adapted to your game logic. for example, if you execute init() and login() but the user
		// doesn't login, cancel the operation, it will return: 0 -1 0 -1 , same as if the user is
		// not connected to the internet.
		Lib.trace("Login result = "+result);
	}
	
}
```

###Get player info and friends example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;
import extension.gpg.Player;

class MainClass {

	function new() {
		GooglePlayGames.onLoadConnectedPlayers = onLoadConnectedPlayers;
		GooglePlayGames.onLoadInvitablePlayers = onLoadInvitablePlayers;
		GooglePlayGames.onLoginResult = loginCallback;
		GooglePlayGames.init(true);
		GooglePlayGames.login();
	}
	
	function loginCallback(result:Int):Void {
		if(result == 1){
			trace("Player ID: "+GooglePlayGames.getPlayerId());
			trace("Player Display Name: "+GooglePlayGames.getPlayerDisplayName());

			// Load invitable friends (people you can invite to play)
			// the boolean parameter (in false here) indicates if you want GPG to clear the players
			// cache. You should only set this to true when the player request a reload manually.
			GooglePlayGames.loadInvitablePlayers(false);

			// Load connected friends (people already connected to your game on GPG)
			// the boolean parameter (in false here) indicates if you want GPG to clear the players
			// cache. You should only set this to true when the player request a reload manually.
			GooglePlayGames.loadConnectedPlayers(false);
		}
	}

	function onLoadInvitablePlayers(players:Array<Player>){
		for(p in players) trace(p.id + ": " + p.name);
		trace("GET "+players.length+" INVITABLE PLAYERS!");
	}

	function onLoadConnectedPlayers(players:Array<Player>){
		for(p in players) trace(p.id + ": " + p.name);
		trace("GET "+players.length+" CONNECTED PLAYERS!");
	}

	
}


```

###Get player image example

```haxe
// This example show a simple use case. The method loadPlayerImage retrieves 
// the player image, saves it locally in cache and calls onLoadPlayerImage 
// with the player id and the path of the image as parameters.

//if the id parameter of loadPlayerImage is null, the methods retrieves the image for the current player 

import extension.gpg.GooglePlayGames;
import extension.gpg.Player;

class MainClass {

	function new() {
		GooglePlayGames.onLoadConnectedPlayers = onLoadConnectedPlayers;
		GooglePlayGames.onLoadPlayerImage = onLoadPlayerImage;
		GooglePlayGames.onLoginResult = loginCallback;
		GooglePlayGames.init(true);
		GooglePlayGames.login();
	}
	
	function loginCallback(result:Int):Void {
		if(result == 1){
			GooglePlayGames.loadPlayerImage(null);
			GooglePlayGames.loadConnectedPlayers(false);
		}
	}

	function onLoadPlayerImage(id:String, path:String){
		trace("The path to the image of the player "+id+" is: "+path);
	}

	function onLoadConnectedPlayers(players:Array<Player>){
		for(p in players) loadPlayerImage(p.id);
	}

	
}


```

###XML Resources parsing example

```haxe
// This example show a simple use case.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method.
		// the boolean parameter is to enable cloud storage service. Note that google and will
		// prompt for that permission to the user the first time.
		GooglePlayGames.init(true);
		// IMPORTANT: If you call init(true) you're enabling Saved Games API, so remember to enable
		// that feature on your google play games console to avoid Runtime Errors.
		// If you don't want to use Saved Games API, just calal GooglePlayGames.init(false);		
		
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

###Get player score example

```haxe
// This example show a simple use case whit the method getPlayerScore.
// Explanations whit the methods getCurrentAchievementSteps and
// getAchievementStatus.

import extension.gpg.GooglePlayGames;

class MainClass {

	function new() {
		// first of all... call init on the main method.
		// the boolean parameter is to enable cloud storage service. Note that google and will
		// prompt for that permission to the user the first time.
		// Set up the player score result event callback first, always before init().
		GooglePlayGames.onGetPlayerScore = playerScoreCallback; // Work with Int data type.
		GooglePlayGames.onGetPlayerScore64 = playerScore64Callback; // Work with Long data type.
		GooglePlayGames.init(true);
		// IMPORTANT: If you call init(true) you're enabling Saved Games API, so remember to enable
		// that feature on your google play games console to avoid Runtime Errors.
		// If you don't want to use Saved Games API, just calal GooglePlayGames.init(false);		
	}
	
	function getPlayerScoreFromScoreboard() {
		// Call getPlayerScore passing the idScoreboard.
		// This function returns False if the user is not logged into the game.
		GooglePlayGames.getPlayerScore("your-scoreboard-id"); // Same function for both data types (Int/Long).
	}
	
	function playerScoreCallback(idScoreboard:String, score:Int):Void {
		// This function must be adapted to your game logic.
		Lib.trace("ID Scoreboard: "+ idScoreboard +". Score: "+ score);
	}
	
	function playerScoreCallback64(idScoreboard:String, score:Int64):Void {
		// This function must be adapted to your game logic.
		Lib.trace("ID Scoreboard: "+ idScoreboard +". Score: "+ score);
	}
	
	// Note that, the functions:
	//			* GooglePlayGames.getCurrentAchievementSteps("your-achievement-id")
	//			* GooglePlayGames.getAchievementStatus("your-achievement-id")
	// Works with the same logic. Both must be set up the result event callback first.
	//			* GooglePlayGames.onGetPlayerAchievementStatus = callbackStatus;
	//			* GooglePlayGames.onGetPlayerCurrentSteps = callbackSteps;
	// Both functions returns false if the user is not logged into the game.
	//			* function callbackStatus(idAchievement:String, status:String): Void
	//			* function callbackSteps(idAchievement:String, steps:Int): Void
	
}
```

###How to Install

To install this library, you can simply get the library from haxelib like this:
```bash
haxelib install extension-googleplaygames
```

Once this is done, you just need to add this to your project.xml
```xml
<haxelib name="extension-googleplaygames" />
<setenv name="GOOGLE_PLAY_GAMES_ID" value="32180581421" /> <!-- REPLACE THIS WITH YOUR GOOGLE PLAY GAMES ID! -->
```

Also, you may need to set android sdk version to 23 or higher (as some versions of google play services requires this:
```xml
<android target-sdk-version="23" if="android" />
```

###Disclaimer

Google is a registered trademark of Google Inc.
http://unibrander.com/united-states/140279US/google.html

###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy; 2013 SempaiGames (http://www.sempaigames.com)

Author: Federico Bricker
