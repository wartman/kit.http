package kit.http.client;

import kit.http.server.MockServer;
import haxe.Timer;

typedef MockClientOptions = {
	public final ?timeout:Int;
}

class MockClient implements Client {
	final server:MockServer;
	final options:MockClientOptions;

	public function new(server, ?options) {
		this.server = server;
		this.options = options;
	}

	public function request(request:Request):Task<Response> {
		return new Task(activate -> {
			var link:Null<Cancellable> = null;
			var timer = Timer.delay(() -> {
				link?.cancel();
				activate(Error(new Error(RequestTimeout, 'Request timed out.')));
			}, options?.timeout ?? 1000);
			link = server.handleRequest(request).handle(response -> {
				timer.stop();
				timer = null;
				activate(Ok(response));
			});
		});
	}
}
