package kit.http.server;

import kit.http.Server;

private enum MockServerOptions {
	Port(port:Int);
	Url(url:Url);
	None;
}

abstract MockServerInit(MockServerOptions) from MockServerOptions to MockServerOptions {
	@:from public static function ofString(path:String):MockServerInit {
		return Url(path);
	}

	@:from public static function ofUrl(url:Url):MockServerInit {
		return Url(url);
	}

	@:from public static function ofPort(port:Int):MockServerInit {
		return Port(port);
	}
}

class MockServer implements Server {
	final options:MockServerOptions;

	final public function new(?init:MockServerInit) {
		this.options = init ?? None;
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		var context = MockServerContext.current();

		return new Future(activate -> {
			var link = context.onRequest.add(request -> {
				// @todo: only respond if the request matches the MockServerOptions
				handler.process(request).handle(response -> context.onResponse.dispatch(response));
			});

			activate(Running(finish -> {
				link.cancel();
				finish(true);
			}));
		});
	}
}

class MockServerContext {
	public static function current() {
		static var context = null;
		if (context == null) {
			context = new MockServerContext();
		}
		return context;
	}

	public final onRequest:Event<Request> = new Event<Request>();
	public final onResponse:Event<Response> = new Event<Response>();

	private function new() {}
}
