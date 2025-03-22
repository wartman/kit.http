package kit.http.shared;

import kit.Cancellable;

class MockConnection implements CancellableLink {
	public final request:Event<Request> = new Event<Request>();
	public final respond:Event<Response> = new Event<Response>();

	public function new() {}

	public function isCanceled():Bool {
		return request.isCanceled() || respond.isCanceled();
	}

	public function cancel() {
		request.cancel();
		respond.cancel();
	}
}
