package gpgex;

class GooglePlayGames {
	public static var checkPlayServices(default,null):Void->Bool=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gcmex/GCM", "checkPlayServices", "()Z");
	#else
		function():Bool{return false;}
	#end

	public static var getRegistrationId(default,null):Void->String=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gcmex/GCM", "getRegistrationId", "()Ljava/lang/String;");
	#else
		function():String{return null;}
	#end

	private static var realInit(default,null):String->Dynamic->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gcmex/GCM", "init", "(Ljava/lang/String;Lorg/haxe/lime/HaxeObject;)V");
	#else
		function(senderId:String,callback:Dynamic):Void{}
	#end

	public static var sendMessage(default,null):String->Void=
	#if android
		openfl.utils.JNI.createStaticMethod("com/gcmex/GCM", "sendMessage", "(Ljava/lang/String;)V");
	#else
		function(msg:String):Void{}
	#end

	public static function init(senderId:String){
		realInit(senderId,getInstance());
	}

	private static function getInstance():GCM{
		if(instance==null) instance=new GCM();
		return instance;
	}

	private static var instance:GCM=null;
	public static var onReceive:String->String->Void=null;
	
	private function new(){}

	public function receiveCallback(type:String, json:String){
		if(onReceive==null){
			trace("RECEIVED: "+type+" = "+json);
		}else{
			onReceive(type,json);
		}
	}
}
