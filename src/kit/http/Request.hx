package kit.http;

class Request extends Message<Request> {
	public static function ofUrl(url:Url) {
		return new Request(Get, url);
	}

	public final url:Url;
	public final method:Method;

	public function new(method, url:Url, ?headers:Headers, ?body) {
		// // @todo: Following psr-7 here, but we probably shouldn't set `host`
		// // due to the fact that it's likely handled by our target-specific
		// // Clients. Come back to this later.
		//
		// if (headers == null) headers = new Headers();
		//
		// headers = if (headers.has(Host)) {
		// 	headers;
		// } else {
		// 	headers.prepend(new HeaderField(Host, url.host ?? '*'));
		// }

		super(headers, body);
		this.method = method;
		this.url = url;
	}

	public function withUrl(url:Url /*, ?options:{preserveHost:Bool}*/):Request {
		// // See note in constructor.
		// //
		// var headers = if (options?.preserveHost == true) {
		// 	headers;
		// } else {
		// 	headers.without(Host).prepend(new HeaderField(Host, url.host ?? '*'));
		// }

		return new Request(method, url, headers, body);
	}

	public function withHeader(header:HeaderField):Request {
		return new Request(method, url, headers.with(header), body);
	}

	public function withoutHeader(header:HeaderName):Request {
		return new Request(method, url, headers.without(header), body);
	}

	public function withBody(body:Body):Request {
		return new Request(method, url, headers, body);
	}

	public function withMethod(method:Method) {
		return new Request(method, url, headers, body);
	}
}
