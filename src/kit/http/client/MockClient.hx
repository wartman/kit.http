package kit.http.client;

import haxe.Timer;
import kit.http.server.MockServer;

class MockClient implements Client {
	final options:{
		?timeout:Int
	};

	public function new(?options) {
		this.options = options ?? {timeout: 1000};
	}

	public function request(request:Request):Task<Response> {
		var context = MockServerContext.current();
		return new Task(activate -> {
			var link:Null<Cancellable> = null;
			var timer = Timer.delay(() -> {
				link?.cancel();
				activate(Error(new Error(RequestTimeout, 'Request timed out.')));
			}, options.timeout);
			link = context.onResponse.addOnce(response -> {
				timer.stop();
				timer = null;
				activate(Ok(response));
			});
			context.onRequest.dispatch(request);
		});
	}
}
