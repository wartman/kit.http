package kit.http;

@:forward
abstract Handler(HandlerObject) from HandlerObject {
	@:from public inline static function ofFunction(handle):Handler {
		return new SimpleHandler(handle);
	}

	public function new(handle) {
		this = new SimpleHandler(handle);
	}

	public inline function apply(mw:Middleware):Handler {
		return mw.apply(this);
	}
}

interface HandlerObject {
	public function handle(request:Request):Future<Response>;
}

class SimpleHandler implements HandlerObject {
	final handler:(request:Request) -> Future<Response>;

	public function new(handler) {
		this.handler = handler;
	}

	public function handle(request:Request):Future<Response> {
		return handler(request);
	}
}
