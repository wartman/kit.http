package kit.http;

import haxe.io.Encoding;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

using Kit;

@:forward
abstract Body(BodyObject) {
	@:from public inline static function ofBytes(bytes:Bytes):Body {
		return new Body(bytes);
	}

	@:from public inline static function ofString(str:String):Body {
		return new Body(Bytes.ofString(str));
	}

	@:from public inline static function ofJson<T:{}>(data:T):Body {
		return new Body(Bytes.ofString(Json.stringify(data)));
	}

	public inline function new(?bytes) {
		this = new BodyObject(bytes);
	}
}

class BodyObject {
	var buffer:Maybe<BytesBuffer> = None;
	var body:Maybe<Bytes> = None;

	public function new(?body) {
		if (body != null) {
			this.body = Some(body);
		}
	}

	public function replace(value:Bytes):Void {
		if (value == null) return;

		var buf = new BytesBuffer();
		buf.addBytes(value, 0, value.length);
		buffer = Some(buf);
	}

	public function write(value:String, ?encoding:Encoding) {
		switch buffer {
			case None: buffer = Some(new BytesBuffer());
			default:
		}
		buffer.inspect(buffer -> buffer.addString(value, encoding));
	}

	public function toBytes():Maybe<Bytes> {
		body.extract(if (Some(_)) return body);

		return switch buffer {
			case None:
				None;
			case Some(buf):
				body = Some(buf.getBytes());
				buffer = None;
				body;
		}
	}

	public function toString():Maybe<String> {
		return toBytes().map(value -> value.toString());
	}

	public function toJson<T:{}>():Maybe<T> {
		return toString().map(Json.parse);
	}
}
