package gpgex;

class GooglePlayGames {

	private static var javaInit(default,null):Void->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "()V");
	#else
		function():Void{}
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

	public static function init(stage:flash.display.Stage){
		#if android
			javaInit();
			stage.addEventListener(flash.events.Event.RESIZE,function(_){javaInit();});
		#end
	}

}
