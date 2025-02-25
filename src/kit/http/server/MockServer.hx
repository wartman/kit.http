package kit.http.server;

import kit.http.Server;

class MockServer implements Server {
	final onRequest:Event<Request> = new Event<Request>();
	final onResponse:Event<Response> = new Event<Response>();

	public function new(?watcher) {
		if (watcher != null) onResponse.add(watcher);
	}

	public function request(request:Request) {
		onRequest.dispatch(request);
		return this;
	}

	public function watch(handler:(response:Response) -> Void):Cancellable {
		return onResponse.add(handler);
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		return new Future(activate -> {
			var link = onRequest.add(request -> {
				handler.process(request).handle(response -> onResponse.dispatch(response));
			});

			activate(Running(finish -> {
				link.cancel();
				finish(true);
			}));
		});
	}
}
