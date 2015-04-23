package extension.gpg;

import haxe.Int64;

class GooglePlayGames {

	public static inline var ACHIEVEMENT_STATUS_LOCKED:Int = 0;
	public static inline var ACHIEVEMENT_STATUS_UNLOCKED:Int = 1;

	//////////////////////////////////////////////////////////////////////
	///////////// LOGIN & INIT 
	//////////////////////////////////////////////////////////////////////

	private static var javaInit(default,null):Bool->GooglePlayGames->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "(ZLorg/haxe/lime/HaxeObject;)V");
	#else
		function(enableCloudStorage:Bool, callbackObject:GooglePlayGames):Void{}
	#end

	public static var login(default,null):Void->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "login", "()V");
	#else
		function():Void{}
	#end

	//////////////////////////////////////////////////////////////////////
	///////////// SAVED GAMES
	//////////////////////////////////////////////////////////////////////

	public static var displaySavedGames(default,null):Void->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displaySavedGames", "()V");
	#else
		function():Void{}
	#end
	
	public static var discardAndCloseGame(default,null):Void->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "discardAndCloseGame", "()Z");
	#else
		function():Bool { return false; }
	#end

	public static var commitAndCloseGame(default,null):String->String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "commitAndCloseGame", "(Ljava/lang/String;Ljava/lang/String;)Z");
	#else
		function(data:String, description:String):Bool { return false; }
	#end

	public static var loadSavedGame(default,null):String->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "loadSavedGame", "(Ljava/lang/String;)V");
	#else
		function(name:String):Void{}
	#end

	public function onLoadSavedGame(name:String, statusCode:Int, data:String){
		trace("onLoadSavedGame");
		trace(name+" STATUS: "+statusCode);
		trace("DATA: "+data);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// LEADERBOARDS
	//////////////////////////////////////////////////////////////////////

	public static var displayScoreboard(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayScoreboard", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

	public static var displayAllScoreboards(default,null):Void->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAllScoreboards", "()Z");
	#else
		function():Bool{return false;}
	#end

	private static var javaSetScore(default,null):String->Int->Int->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setScore", "(Ljava/lang/String;II)Z");
	#else
		function(id:String,high_score:Int, low_score:Int):Bool{return false;}
	#end

	public static function setScore(id:String, score:Int):Bool {
		return javaSetScore(id, 0, score);
	}

	public static function setScore64(id:String, score:Int64):Bool {
		var low_score:Int = Int64.getLow(score);
		var high_score:Int = Int64.getHigh(score);
		return javaSetScore(id, high_score, low_score);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS
	//////////////////////////////////////////////////////////////////////

	public static var displayAchievements(default,null):Void->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayAchievements", "()Z");
	#else
		function():Bool{return false;}
	#end

	public static var unlock(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "unlock", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

	public static var increment(default,null):String->Int->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "increment", "(Ljava/lang/String;I)Z");
	#else
		function(id:String,step:Int):Bool{return false;}
	#end

	public static var reveal(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "reveal", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

	public static var setSteps(default,null):String->Int->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setSteps", "(Ljava/lang/String;I)Z");
	#else
		function(id:String,steps:Int):Bool{return false;}
	#end

	//////////////////////////////////////////////////////////////////////
	///////////// COULD STORAGE
	//////////////////////////////////////////////////////////////////////

	public static var cloudSet(default,null):Int->String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "cloudSet", "(ILjava/lang/String;)Z");
	#else
		function(key:Int,value:String):Bool{return false;}
	#end

	public static var cloudGet(default,null):Int->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "cloudGet", "(I)Z");
	#else
		function(key:Int):Bool{return false;}
	#end

	//////////////////////////////////////////////////////////////////////
	///////////// HAXE IMPLEMENTATIONS
	//////////////////////////////////////////////////////////////////////

	public static function init(stage:flash.display.Stage, enableCloudStorage:Bool){
		#if android
			if(initted){
				trace("GooglePlayGames: WONT INIT TWICE!");
				return;
			}
			initted=true;
			javaInit(enableCloudStorage,getInstance());
			stage.addEventListener(flash.events.Event.RESIZE,function(_){javaInit(enableCloudStorage,getInstance());});
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

	public static var onCloudGetComplete:Int->String->Void=null;
	public static var onCloudGetConflict:Int->String->String->Void=null;
	private static var initted:Bool=false;

	private static var instance:GooglePlayGames=null;

	private static function getInstance():GooglePlayGames{
		if(instance==null) instance=new GooglePlayGames();
		return instance;
	}

	private function new(){}
	
	public function cloudGetCallback(key:Int, value:String){
		if(onCloudGetComplete!=null) onCloudGetComplete(key,value);
	}

	public function cloudGetConflictCallback(key:Int, localValue:String, serverValue:String){
		trace("Conflict versions on KEY: "+key+". Local: "+localValue+" - Server: "+serverValue);
		if(onCloudGetConflict!=null) onCloudGetConflict(key,localValue,serverValue);
	}

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

	public static var getPlayerScore(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getPlayerScore", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

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

	public static var onGetPlayerAchievementStatus:String->Int->Void=null;

	public static var getAchievementStatus(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getAchievementStatus", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

	public function onGetAchievementStatus(idAchievement:String, state:Int) {
		if (onGetPlayerAchievementStatus != null) onGetPlayerAchievementStatus(idAchievement, state);
	}

	//////////////////////////////////////////////////////////////////////
	///////////// ACHIEVEMENTS CURRENT STEPS
	//////////////////////////////////////////////////////////////////////

	public static var onGetPlayerCurrentSteps:String->Int->Void=null;

	public static var getCurrentAchievementSteps(default,null):String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "getCurrentAchievementSteps", "(Ljava/lang/String;)Z");
	#else
		function(id:String):Bool{return false;}
	#end

	public function onGetAchievementSteps(idAchievement:String, steps:Int) {
		if (onGetPlayerCurrentSteps != null) onGetPlayerCurrentSteps(idAchievement, steps);
	}
	
}