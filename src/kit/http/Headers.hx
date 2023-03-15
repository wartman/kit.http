package kit.http;

import haxe.Exception;

using Lambda;
using kit.Sugar;

@:forward(iterator, keyValueIterator)
abstract Headers(Array<HeaderField>) from Array<HeaderField> {
	public static function parse(value:String):Result<Headers> {
		return Failure(new Exception('Not implemented yet'));
	}

	public function new(...fields) {
		this = fields.toArray();
	}

	public function find(name:HeaderName):Maybe<HeaderField> {
		return this.find(header -> header.name == name).toMaybe();
	}

	public function get(name:HeaderName):Array<HeaderField> {
		return [for (field in this) if (field.name == name) field];
	}

	public inline function has(name:HeaderName) {
		return this.exists(field -> field.name == name);
	}

	public inline function with(...headers:HeaderField):Headers {
		return this.concat(headers.toArray());
	}

	public inline function without(name:HeaderName):Headers {
		return this.filter(field -> field.name != name);
	}

	public inline function clone():Headers {
		return this.copy();
	}

	public function toString() {
		// todo
		return '';
	}
}