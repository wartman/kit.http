package kit.http;

@:forward
abstract Handler(HandlerObject) from HandlerObject {
	@:from public inline static function ofFunction(handle):Handler {
		return new SimpleHandler(handle);
	}

	public function new(handle) {
		this = new SimpleHandler(handle);
	}

	public inline function into(...mws:Middleware):Handler {
		var handler:Handler = this;
		for (mw in mws) handler = mw.apply(handler);
		return handler;
	}
}

interface HandlerObject {
	public function process(request:Request):Future<Response>;
}

class SimpleHandler implements HandlerObject {
	final handle:(request:Request) -> Future<Response>;

	public function new(handle) {
		this.handle = handle;
	}

	public function process(request:Request):Future<Response> {
		return handle(request);
	}
}
