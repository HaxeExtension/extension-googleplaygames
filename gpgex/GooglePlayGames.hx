package gpgex;

class GooglePlayGames {

	public static var init(default,null):Void->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "init", "()V");
	#else
		function():Void{}
	#end

	public static var displayScoreBoard(default,null):String->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gpgex/GooglePlayGames", "displayScoreBoard", "(Ljava/lang/String;)V");
	#else
		function(msg:String):Void{}
	#end

}
