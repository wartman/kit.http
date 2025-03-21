package kit.http;

import kit.http.client.*;
import kit.http.server.*;

class HandlerSuite extends Suite {
	function startServer(handler):Task<(handle:(status:Bool) -> Void) -> Void> {
		var server = new MockServer(8080);
		return server.serve(handler).map(status -> switch status {
			case Failed(e): Error(new Error(InternalError, e.message));
			case Closed: Error(new Error(InternalError, 'Server failed to start'));
			case Running(close): Ok(close);
		});
	}

	@:test(expects = 1, timeout = 100)
	function handlerWorks() {
		var client = new MockClient();
		return startServer(request -> {
			return Future.immediate(new Response(OK, [], 'Works'));
		}).next(close -> {
			client.request(new Request(Get, 'http://localhost:8080'))
				.inspect(response -> {
					response.body.toString().extract(if (Some(value)) {
						value.equals('Works');
					} else {
						Assert.fail('No body was sent');
					});
				})
				.always(() -> close(_ -> null));
		});
	}
}
