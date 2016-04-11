package extension.gpg;

class Player {
	public var id(default,null):String;
	public var name(default,null):String;

	public function new(id:String, name:String) {
		this.id = id;
		this.name = name;
	}
}