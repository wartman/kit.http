package kit.http.server;

import kit.http.shared.MockConnection;
import kit.http.Server;

class MockServer implements Server {
	final connection:MockConnection;

	final public function new(connection) {
		this.connection = connection;
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		return new Future(activate -> {
			var link = connection.request.add(request -> {
				handler.process(request).handle(response -> connection.respond.dispatch(response));
			});

			activate(Running(finish -> {
				link.cancel();
				finish(true);
			}));
		});
	}
}
