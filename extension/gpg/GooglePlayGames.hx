package extension.gpg;

import haxe.Int64;
import flash.Lib;

class GooglePlayGames {

	public static inline var ACHIEVEMENT_STATUS_LOCKED:Int = 0;
	public static inline var ACHIEVEMENT_STATUS_UNLOCKED:Int = 1;

	//////////////////////////////////////////////////////////////////////
	///////////// LOGIN & INIT 
	//////////////////////////////////////////////////////////////////////

	private static var javaInit(default,null) : Bool->GooglePlayGames->Void = null;
	private static var iosInit(default,null) : Bool->Dynamic->String->Void = null;
	public static var login(default,null) : Void->Void = function():Void{}

	//////////////////////////////////////////////////////////////////////
	///////////// PLAYER INFO
	//////////////////////////////////////////////////////////////////////

	public static var getPlayerId(default,null) : Void->String = function():String { return null; }
	public static var getPlayerDisplayName(default,null) : Void->String = function():String { return null; }
	public static var getPlayerImage(default,null) : String->Void = function(id:String):Void {}

	//////////////////////////////////////////////////////////////////////
	///////////// SAVED GAMES
	//////////////////////////////////////////////////////////////////////

	public static var displaySavedGames(default,null) : String->Bool->Bool->Int->Void = function(title:String, allowAddButton:Bool, allowDelete:Bool, maxNumberOfSavedGamesToShow:Int):Void{}
	public static var discardAndCloseGame(default,null) : Void->Bool = function():Bool { return false; }
	public static var commitAndCloseGame(default,null) : String->String->Bool = function(data:String, description:String):Bool { return false; }
	public static var loadSavedGame(default,null) : String->Void = function(name:String):Void{}

	private function onLoadSavedGameComplete(name:String, statusCode:Int, data:String) {
		if(onLoadGameComplete!=null) onLoadGameComplete(name,data);
	}

	private function onLoadSavedGameConflict(name:String, data:String, conflictData:String) {
		if(onLoadGameConflict!=null) onLoadGameConflict(name,data,conflictData);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// LEADERBOARDS
	//////////////////////////////////////////////////////////////////////

	public static var displayScoreboard(default,null) : String->Bool = function(id:String):Bool{return false;}
	public static var displayAllScoreboards(default,null) : Void->Bool = function():Bool{return false;}
	private static var javaSetScore(default,null) : String->Int->Int->Bool = function(id:String,high_score:Int, low_score:Int):Bool{return false;}

	public static function setScore(id:String, score:Int):Bool {
		return javaSetScore(id, 0, score);
	}

	public static function setScore64(id:String, score:Int64):Bool {
		return javaSetScore(id, score.high, score.low);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS
	//////////////////////////////////////////////////////////////////////

	public static var displayAchievements(default,null) : Void->Bool = function():Bool{return false;}
	public static var unlock(default,null) : String->Bool = function(id:String):Bool{return false;}
	public static var increment(default,null) : String->Int->Bool = function(id:String,step:Int):Bool{return false;}
	public static var reveal(default,null) : String->Bool = function(id:String):Bool{return false;}
	public static var setSteps(default,null) : String->Int->Bool = function(id:String,steps:Int):Bool{return false;}

	//////////////////////////////////////////////////////////////////////
	///////////// FRIENDS
	//////////////////////////////////////////////////////////////////////

	public static var loadInvitablePlayers(default,null) : Bool->Bool = function(clearCache:Bool):Bool{return false;}
	public static var loadConnectedPlayers(default,null) : Bool->Bool = function(clearCache:Bool):Bool{return false;}

	//////////////////////////////////////////////////////////////////////
	///////////// HAXE IMPLEMENTATIONS
	//////////////////////////////////////////////////////////////////////

	public static function init(enableCloudStorage:Bool, iosCliendID:String=null){
		if(initted){
			trace("GooglePlayGames: WONT INIT TWICE!");
			return;
		}
		initted=true;
		#if android

			try {
				// LINK JNI METHODS
				javaInit = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "(ZLorg/haxe/lime/HaxeObject;)V");
				login = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "login", "()V");
				displaySavedGames = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displaySavedGames", "(Ljava/lang/String;ZZI)V");
				discardAndCloseGame = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "discardAndCloseGame", "()Z");
				commitAndCloseGame = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "commitAndCloseGame", "(Ljava/lang/String;Ljava/lang/String;)Z");
				loadSavedGame = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadSavedGame", "(Ljava/lang/String;)V");
				displayScoreboard = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayScoreboard", "(Ljava/lang/String;)Z");
				displayAllScoreboards = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAllScoreboards", "()Z");
				javaSetScore = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setScore", "(Ljava/lang/String;II)Z");
				displayAchievements = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAchievements", "()Z");
				unlock = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "unlock", "(Ljava/lang/String;)Z");
				increment = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "increment", "(Ljava/lang/String;I)Z");
				reveal = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "reveal", "(Ljava/lang/String;)Z");
				setSteps = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setSteps", "(Ljava/lang/String;I)Z");
				getPlayerScore = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerScore", "(Ljava/lang/String;)Z");
				getAchievementStatus = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getAchievementStatus", "(Ljava/lang/String;)Z");
				getCurrentAchievementSteps = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getCurrentAchievementSteps", "(Ljava/lang/String;)Z");
				getPlayerId = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerId", "()Ljava/lang/String;");
				getPlayerDisplayName = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerDisplayName", "()Ljava/lang/String;");
				getPlayerImage = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerImage", "(Ljava/lang/String;)V");
				loadInvitablePlayers = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadInvitablePlayers", "(Z)Z");
				loadConnectedPlayers = openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadConnectedPlayers", "(Z)Z");

			} catch(e:Dynamic) {
				trace("GooglePlayGames linkMethods Exception: "+e);
			}

			javaInit(enableCloudStorage,getInstance());
			openfl.Lib.current.stage.addEventListener(flash.events.Event.RESIZE,function(_){javaInit(enableCloudStorage,getInstance());});
		#elseif ios
			if(iosCliendID == null){
				trace("ERROR: You must send iosClientID when calling init on IOS:");
				trace("Example: GooglePlayGames.init(false,'1231287387123-qm1ms2vp123123178dp9vq14s1oej38thheel.apps.googleusercontent.com');");
				return;
			}
			try{
				trace("linking ios methods");
				iosInit = Lib.load("GooglePlayGamesExtension", "googleplaygames_init", 3);
				login = Lib.load("GooglePlayGamesExtension", "googleplaygames_login", 0);
				iosInit(true, getInstance()._onCallback, iosCliendID);
			} catch(e:Dynamic){
				trace("GooglePlayGames linkMethods Exception: "+e);
			}
		#end
	}

	//////////////////////////////////////////////////////////////////////
	///////////// UTILS: ID MANAGEMENT
	//////////////////////////////////////////////////////////////////////

	public static var id(default,null):Map<String,String>=new Map<String,String>();
	public static var onLoginResult:Int->Void=null;

	public static function loadResourcesFromXML(text:String){
		text=text.split("<resources>")[1];
		text=StringTools.replace(text,"<string name=\"","");
		for(line in text.split("</string>")){
			var arr=StringTools.trim(line).split("\">");
			if(arr.length!=2) continue;
			id.set(arr[0],arr[1]);
		}
	}

	public static function getID(alias:String):String{
		if(!id.exists(alias)){
			trace("CANT FIND ID FOR ALIAS: "+alias);
			trace("PLEASE MAKE SURE YOU'VE LOADED RESOURCES USING loadResourcesFromXML FIRST!");
			return null;
		}
		return id.get(alias);
	}
	
	//////////////////////////////////////////////////////////////////////
	///////////// EVENTS RECEPTION
	//////////////////////////////////////////////////////////////////////

	public static var onLoadGameComplete:String->String->Void=null;
	public static var onLoadGameConflict:String->String->String->Void=null;

	private static var initted:Bool=false;

	private static var instance:GooglePlayGames=null;

	private static function getInstance():GooglePlayGames{
		if(instance==null) instance=new GooglePlayGames();
		return instance;
	}

	private function new(){}

	//posible returns are: -1 = login failed | 0 = initiated login | 1 = login success
	//the event is fired in differents circumstances, like if you init and do not login,
	//can return -1 or 1 but if you log in, will return a series of 0 -1 0 -1 if there is no
	//connection for example. test it and adapt it to your code and logic.
	public function loginResultCallback(res:Int) {
		if(onLoginResult!=null) onLoginResult(res);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// GET PLAYER SCORE
	//////////////////////////////////////////////////////////////////////
	
	public static var onGetPlayerScore:String->Int->Void=null;
	public static var onGetPlayerScore64:String->Int64->Void=null;
	public static var getPlayerScore(default,null) : String->Bool = function(id:String):Bool{return false;}


	public function onGetScoreboard(idScoreboard:String, high_score:Int, low_score:Int) {
		if (onGetPlayerScore != null) onGetPlayerScore(idScoreboard, low_score);
		if (onGetPlayerScore64 != null) {
			var score:Int64 = Int64.make(high_score, low_score);
			onGetPlayerScore64(idScoreboard, score);
		}
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENT STATUS
	//////////////////////////////////////////////////////////////////////

	public static var onGetPlayerAchievementStatus : String->Int->Void = null;
	public static var getAchievementStatus(default,null) : String->Bool = function(id:String):Bool{return false;}

	public function onGetAchievementStatus(idAchievement:String, state:Int) {
		if (onGetPlayerAchievementStatus != null) onGetPlayerAchievementStatus(idAchievement, state);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS CURRENT STEPS
	//////////////////////////////////////////////////////////////////////

	public static var onGetPlayerCurrentSteps : String->Int->Void = null;
	public static var getCurrentAchievementSteps(default,null) : String->Bool = function(id:String):Bool{return false;}

	public function onGetAchievementSteps(idAchievement:String, steps:Int) {
		if (onGetPlayerCurrentSteps != null) onGetPlayerCurrentSteps(idAchievement, steps);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// FRIENDS
	//////////////////////////////////////////////////////////////////////

	public static var onLoadConnectedPlayers : Array<Player>->Void = null;
	public static var onLoadInvitablePlayers : Array<Player>->Void = null;

	public function onLoadPlayers(players:String, connectedPlayers:Bool) {
		if(connectedPlayers && onLoadConnectedPlayers==null) return;
		if(!connectedPlayers && onLoadInvitablePlayers==null) return;

		var res = new Array<Player>();
		var data = new Array<String>();
		for(player in players.split(String.fromCharCode(2))){
			if(player == "") continue;
			data = player.split(String.fromCharCode(1));
			if(data.length!=2) continue;
			res.push(new Player(data[0],data[1]));
		}
		if(connectedPlayers) {
			onLoadConnectedPlayers(res);
		}else{
			onLoadInvitablePlayers(res);
		}
	}

	//////////////////////////////////////////////////////////////////////
	///////////// PICTURES
	//////////////////////////////////////////////////////////////////////

	public static var onLoadPlayerImage : String->String->Void = null;

	public function onGetPlayerImage(id:String, path:String) {
		if(onLoadPlayerImage!=null) onLoadPlayerImage(id, path);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// CALLBACKS HANDLER
	//////////////////////////////////////////////////////////////////////

	public static inline var ON_INIT:String = "init";

	public function _onCallback(name:String, data1:String, data2:String){
		trace("==========  on callback!! ===========");
		switch(name){
			case ON_INIT:{
				trace("init :D :D");
			}
		}
	}
	
}