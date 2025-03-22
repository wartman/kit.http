package kit.http.client;

import kit.http.shared.MockConnection;
import haxe.Timer;

typedef MockClientOptions = {
	public final ?timeout:Int;
}

class MockClient implements Client {
	final connection:MockConnection;
	final options:MockClientOptions;

	public function new(connection, ?options) {
		this.connection = connection;
		this.options = options;
	}

	public function request(request:Request):Task<Response> {
		return new Task(activate -> {
			var link:Null<Cancellable> = null;
			var timer = Timer.delay(() -> {
				link?.cancel();
				activate(Error(new Error(RequestTimeout, 'Request timed out.')));
			}, options?.timeout ?? 1000);
			link = connection.respond.addOnce(response -> {
				timer.stop();
				timer = null;
				activate(Ok(response));
			});
			connection.request.dispatch(request);
		});
	}
}
