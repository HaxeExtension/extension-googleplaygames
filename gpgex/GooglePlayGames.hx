package gpgex;

class GooglePlayGames {

	private static var javaInit(default,null):Bool->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "(Z)V");
	#else
		function(enableCloudStorage:Bool):Void{}
	#end

	public static var login(default,null):Void->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "login", "()V");
	#else
		function():Void{}
	#end

	public static var displayScoreBoard(default,null):String->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayScoreBoard", "(Ljava/lang/String;)V");
	#else
		function(id:String):Void{}
	#end

	public static var setScore(default,null):String->Int->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "setScore", "(Ljava/lang/String;I)Z");
	#else
		function(id:String,score:Int):Bool{return false;}
	#end

	public static var cloudSet(default,null):Int->String->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "cloudSet", "(ILjava/lang/String;)Z");
	#else
		function(key:Int,value:String):Bool{return false;}
	#end

	private static var javaCloudGet(default,null):Int->Dynamic->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "cloudGet", "(ILorg/haxe/lime/HaxeObject;)Z");
	#else
		function(key:Int):Bool{return false;}
	#end

	public static function init(stage:flash.display.Stage, enableCloudStorage:Bool){
		#if android
			if(initted){
				trace("GooglePlayGames: WONT INIT TWICE!");
				return;
			}
			initted=true;
			javaInit(enableCloudStorage);
			stage.addEventListener(flash.events.Event.RESIZE,function(_){javaInit(enableCloudStorage);});
		#end
	}

	public static function cloudGet(key:Int):Bool{
		#if android
			return javaCloudGet(key, getInstance());
		#else
			return false;
		#end
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
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

}
