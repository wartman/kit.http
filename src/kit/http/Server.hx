package kit.http;

class Server {
	var handler:Handler;

	public function new(handler) {
		this.handler = handler;
	}

	public function serve(adaptor:ServerAdaptor) {
		return adaptor.serve(handler);
	}
}
