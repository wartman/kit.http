package kit.http.server;

import kit.http.Server;

@:allow(kit.http.client.MockClient)
class MockServer implements Server {
	var handler:Null<Handler> = null;

	final public function new() {}

	private function handleRequest(request:Request):Future<Response> {
		if (handler == null) {
			return Future.immediate(new Response(Forbidden, [], 'Server stopped'));
		}
		return handler.process(request);
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		this.handler = handler;
		return new Future(activate -> {
			activate(Running(finish -> {
				handler = null;
				finish(true);
			}));
		});
	}
}
