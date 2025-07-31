package kit.http;

class Response extends Message<Response> {
	public final status:StatusCode;

	public function new(status, ?headers, body:Body) {
		super(headers, body);
		this.status = status;
	}

	public function withStatus(status:StatusCode):Response {
		return new Response(status, headers, body);
	}

	public function withHeader(header:HeaderField):Response {
		return new Response(status, headers.with(header), body);
	}

	public function withoutHeader(header:HeaderName):Response {
		return new Response(status, headers.without(header), body);
	}

	public function withBody(body:Body):Response {
		return new Response(status, headers, body);
	}
}
