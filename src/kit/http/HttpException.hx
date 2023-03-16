package kit.http;

import haxe.Exception;

class HttpException extends Exception {
	public final status:StatusCode;

	public function new(status, message) {
		super(message);
		this.status = status;
	}
}
