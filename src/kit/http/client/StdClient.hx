package kit.http.client;

import haxe.Http;

class StdClient implements Client {
	public function new() {}

	public function request(req:Request):Task<Response> {
		return switch req.url.scheme {
			case 'http' | 'https':
				new Task(activate -> {
					var http = new Http(req.url);
					var status:StatusCode = OK;

					function getHeaders() {
						return new Headers(...[for (name => value in http.responseHeaders) new HeaderField(name, value)]);
					}

					http.onStatus = code -> {
						status = code;
					}
					http.onBytes = data -> {
						var response = new Response(status, getHeaders(), data);
						activate(Ok(response));
					};
					http.onError = msg -> {
						status = status == OK ? InternalServerError : status;
						activate(Ok(new Response(status, getHeaders(), msg)));
					};

					if (req.method == Post) {
						req.body.toBytes().inspect(bytes -> http.setPostBytes(bytes));
					}

					http.request(req.method == Post);
				});
			default:
				new Error(BadRequest, 'Missing Scheme (expected http/https) in URL: ${req.url.toString()}');
		}
	}
}
