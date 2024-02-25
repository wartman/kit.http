package kit.http;

import kit.Stream;
import haxe.Json;
import haxe.io.*;

@:forward
abstract Body(Stream<Bytes>) from Stream<Bytes> to Stream<Bytes> {
	#if nodejs
	@:from
	@:noUsing
	public inline static function ofNodeReadable(readable:js.node.stream.Readable.IReadable):Body {
		return Stream.ofNodeReadable(readable);
	}
	#end

	@:from
	@:noUsing
	public inline static function ofString(str:String):Body {
		return Stream.value(Bytes.ofString(str));
	}

	@:from
	@:noUsing
	public inline static function ofJson<T:{}>(data:T):Body {
		return ofString(Json.stringify(data));
	}

	@:noUsing
	public static function empty() {
		return Stream.empty();
	}

	public function new(bytes:Bytes) {
		this = Stream.value(bytes);
	}

	public function with(bytes:Bytes):Body {
		return this.append(new Body(bytes));
	}

	public function intoBuffer() {
		return this.reduce(new BytesBuffer(), (accumulator, item) -> {
			accumulator.add(item);
			return accumulator;
		});
	}

	public function toString() {
		return intoBuffer().next(buffer -> buffer.getBytes().toString());
	}
}
