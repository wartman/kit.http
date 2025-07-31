package kit.http;

using Lambda;
using kit.Sugar;

@:forward(iterator, keyValueIterator)
abstract Headers(Array<HeaderField>) from Array<HeaderField> {
	public static function parse(value:String):Result<Headers, Error> {
		return Error(new Error(MethodNotAllowed, 'Not implemented yet'));
	}

	public function new(...fields) {
		this = fields.toArray();
	}

	public function get(name:HeaderName):Array<HeaderField> {
		return [for (field in this) if (field.name == name) field];
	}

	public inline function has(name:HeaderName) {
		return this.exists(field -> field.name == name);
	}

	public inline function prepend(header:HeaderField):Headers {
		return [header].concat(this);
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
