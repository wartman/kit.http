package kit.http;

import kit.http.server.*;

class HandlerSuite extends Suite {
	@:test(expects = 1, timeout = 100)
	function handlerWorks() {
		var server = new MockServer(response -> {
			response.body.extract(if (Some(_.toString() => value)) {
				value.equals('Works');
			} else {
				Assert.fail('No body was sent');
			});
		});
		var handler:Handler = request -> {
			return Future.immediate(new Response(OK, [], 'Works'));
		};

		return server.serve(handler).flatMap(status -> switch status {
			case Running(close):
				server.request(new Request(Get, '/'));
				return new Future(activate -> close(_ -> activate(null)));
			default:
				Assert.fail('Server failed to activate');
				return Future.immediate(null);
		});
	}
}
