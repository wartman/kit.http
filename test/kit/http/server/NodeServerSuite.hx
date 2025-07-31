package kit.http.server;

import kit.http.client.StdClient;

class NodeServerSuite extends Suite {
	function startServer(handler):Task<(handle:(status:Bool) -> Void) -> Void> {
		var server = new NodeServer(8080);
		return server.serve(handler).map(status -> switch status {
			case Failed(e): Error(new Error(InternalError, e.message));
			case Closed: Error(new Error(InternalError, 'Server failed to start'));
			case Running(close): Ok(close);
		});
	}

	@:test(expects = 2)
	function nodeServerWorks() {
		return startServer(request -> {
			return Future.immediate(new Response(OK, [
				new HeaderField(ContentType, 'text/plain')
			], 'Hello World'));
		}).then(close -> {
			var client = new StdClient();
			var request = new Request(Get, 'http://localhost:8080', []);
			return client
				.request(request)
				.inspect(response -> {
					response.getHeader(ContentType).inspect(header -> header.value.equals('text/plain'));
					response.body.toString().inspect(value -> value.equals('Hello World'));
				})
				.always(() -> close(_ -> null));
		});
	}
}
