HOW TO BUILD HAXELIB:
$./build.sh  (on MAC and Linux).
>build.bat (on Windows)

HOW TO INSTALL HAXELIB:
$./install.sh (on MAC and Linux).
>install.bat (on Windows)

HOW TO BUILD AND INSTALL:
$./build.sh && ./install.sh (on MAC and Linux).

>build.bat
>install.bat (on Windows)


HOW TO USE FROM HAXE:
On your project XML add.
<haxelib name="openfl-gpg" />
<setenv name="GOOGLE_PLAY_GAMES_ID" value="3218058421" />


// on some place of your haxe APP
import gpgex.GooglePlayGames;


Call:
-----
GooglePlayGames.init(mainStage,true); // first of all... call init on the main method passing the main stage as parameter.
									  // the second parameter is to enable cloud storage service.
GooglePlayGames.login(); // to force a login request to the user.
GooglePlayGames.showSocoreBoard("your-scoreboard-id"); //to open an scoreboard.
GooglePlayGames.setSocre("scoreboard-id",234); // to set 234 points on scoreboard.
...