package kit.http;

class Server {
	var handler:Handler;

	public function new(handler) {
		this.handler = handler;
	}

	public function apply(middleware:Middleware) {
		handler = handler.apply(middleware);
		return this;
	}

	public function serve(adaptor:ServerAdaptor) {
		return adaptor.serve(handler);
	}
}
