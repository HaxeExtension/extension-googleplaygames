package extension.gpg;

import haxe.Int64;
import haxe.Timer;

#if (openfl < "4.0.0")
import openfl.utils.JNI;
#else
import lime.system.JNI;
#end

class GooglePlayGames {

	public static inline var ACHIEVEMENT_STATUS_LOCKED:Int = 0;
	public static inline var ACHIEVEMENT_STATUS_UNLOCKED:Int = 1;

	//////////////////////////////////////////////////////////////////////
	///////////// LOGIN & INIT 
	//////////////////////////////////////////////////////////////////////

	private static var javaInit(default,null) : Bool->GooglePlayGames->Void = function(enableCloudStorage:Bool, callbackObject:GooglePlayGames):Void{}
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

	//////////////////////////////////////////////////////////////////////
	///////////// LEADERBOARDS
	//////////////////////////////////////////////////////////////////////

	public static var displayScoreboard(default,null) : String->Bool = function(id:String):Bool{return false;}
	public static var displayAllScoreboards(default,null) : Void->Bool = function():Bool{return false;}
	public static var getPlayerScore(default,null) : String->Bool = function(id:String):Bool{return false;}
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
	public static var getAchievementStatus(default,null) : String->Bool = function(id:String):Bool{return false;}
	public static var getCurrentAchievementSteps(default,null) : String->Bool = function(id:String):Bool{return false;}

	//////////////////////////////////////////////////////////////////////
	///////////// FRIENDS
	//////////////////////////////////////////////////////////////////////

	public static var loadInvitablePlayers(default,null) : Bool->Bool = function(clearCache:Bool):Bool{return false;}
	public static var loadConnectedPlayers(default,null) : Bool->Bool = function(clearCache:Bool):Bool{return false;}

	//////////////////////////////////////////////////////////////////////
	///////////// HAXE IMPLEMENTATIONS
	//////////////////////////////////////////////////////////////////////

	public static function init(enableCloudStorage:Bool){
		#if android
			if(initted){
				trace("GooglePlayGames: WONT INIT TWICE!");
				return;
			}
			initted=true;

			try {
				// LINK JNI METHODS
				javaInit = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "(ZLorg/haxe/lime/HaxeObject;)V");
				login = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "login", "()V");
				displaySavedGames = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displaySavedGames", "(Ljava/lang/String;ZZI)V");
				discardAndCloseGame = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "discardAndCloseGame", "()Z");
				commitAndCloseGame = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "commitAndCloseGame", "(Ljava/lang/String;Ljava/lang/String;)Z");
				loadSavedGame = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadSavedGame", "(Ljava/lang/String;)V");
				displayScoreboard = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayScoreboard", "(Ljava/lang/String;)Z");
				displayAllScoreboards = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAllScoreboards", "()Z");
				javaSetScore = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setScore", "(Ljava/lang/String;II)Z");
				displayAchievements = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAchievements", "()Z");
				unlock = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "unlock", "(Ljava/lang/String;)Z");
				increment = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "increment", "(Ljava/lang/String;I)Z");
				reveal = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "reveal", "(Ljava/lang/String;)Z");
				setSteps = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setSteps", "(Ljava/lang/String;I)Z");
				getPlayerScore = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerScore", "(Ljava/lang/String;)Z");
				getAchievementStatus = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getAchievementStatus", "(Ljava/lang/String;)Z");
				getCurrentAchievementSteps = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getCurrentAchievementSteps", "(Ljava/lang/String;)Z");
				getPlayerId = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerId", "()Ljava/lang/String;");
				getPlayerDisplayName = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerDisplayName", "()Ljava/lang/String;");
				getPlayerImage = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerImage", "(Ljava/lang/String;)V");
				loadInvitablePlayers = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadInvitablePlayers", "(Z)Z");
				loadConnectedPlayers = JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadConnectedPlayers", "(Z)Z");

			} catch(e:Dynamic) {
				trace("GooglePlayGames linkMethods Exception: "+e);
			}

			javaInit(enableCloudStorage,getInstance());
			openfl.Lib.current.stage.addEventListener(flash.events.Event.RESIZE,function(_){javaInit(enableCloudStorage,getInstance());});
		#end
	}

	//////////////////////////////////////////////////////////////////////
	///////////// UTILS: ID MANAGEMENT
	//////////////////////////////////////////////////////////////////////

	public static var id(default,null):Map<String,String>=new Map<String,String>();

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

	public static var onLoginResult:Int->Void=null;
	public static var onLoadGameComplete:String->String->Void=null;
	public static var onLoadGameConflict:String->String->String->Void=null;
	public static var onGetPlayerScore:String->Int->Void=null;
	public static var onGetPlayerScore64:String->Int64->Void=null;
	public static var onGetPlayerAchievementStatus : String->Int->Void = null;
	public static var onLoadConnectedPlayers : Array<Player>->Void = null;
	public static var onLoadInvitablePlayers : Array<Player>->Void = null;
	public static var onLoadPlayerImage : String->String->Void = null;
	public static var onLoadPlayerImageError : String->Void = null;
	public static var onGetPlayerCurrentSteps : String->Int->Void = null;

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
		if(onLoginResult!=null) Timer.delay(function(){ onLoginResult(res); }, 0);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// GET PLAYER SCORE
	//////////////////////////////////////////////////////////////////////

	public function onGetScoreboard(idScoreboard:String, high_score:Int, low_score:Int) {
		if (onGetPlayerScore != null) Timer.delay(function(){ onGetPlayerScore(idScoreboard, low_score); }, 0);
		if (onGetPlayerScore64 != null) {
			var score:Int64 = Int64.make(high_score, low_score);
			Timer.delay(function(){ onGetPlayerScore64(idScoreboard, score); }, 0);
		}
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENT STATUS
	//////////////////////////////////////////////////////////////////////


	public function onGetAchievementStatus(idAchievement:String, state:Int) {
		if (onGetPlayerAchievementStatus != null) Timer.delay(function(){ onGetPlayerAchievementStatus(idAchievement, state); },0);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS CURRENT STEPS
	//////////////////////////////////////////////////////////////////////

	public function onGetAchievementSteps(idAchievement:String, steps:Int) {
		if (onGetPlayerCurrentSteps != null) Timer.delay(function(){ onGetPlayerCurrentSteps(idAchievement, steps); },0);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// FRIENDS
	//////////////////////////////////////////////////////////////////////

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
			Timer.delay(function(){ onLoadConnectedPlayers(res); },0);
		}else{
			Timer.delay(function(){ onLoadInvitablePlayers(res); },0);
		}
	}

	//////////////////////////////////////////////////////////////////////
	///////////// SAVED GAMES
	//////////////////////////////////////////////////////////////////////

	public function onLoadSavedGameComplete(name:String, statusCode:Int, data:String) {
		if(onLoadGameComplete!=null) Timer.delay(function(){ onLoadGameComplete(name,data); },0);
	}

	public function onLoadSavedGameConflict(name:String, data:String, conflictData:String) {
		if(onLoadGameConflict!=null) Timer.delay(function(){ onLoadGameConflict(name,data,conflictData); },0);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// PICTURES
	//////////////////////////////////////////////////////////////////////

	public function onGetPlayerImage(id:String, path:String) {
		if(onLoadPlayerImage!=null) Timer.delay(function(){ onLoadPlayerImage(id, path); },0);
	}

	public function onGetPlayerImageError(e:String) {
		if(onLoadPlayerImageError!=null) Timer.delay(function(){ onLoadPlayerImageError(e); },0);
	}
	
}
