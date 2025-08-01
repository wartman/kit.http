package kit.http.server;

import php.*;
import kit.http.Server.ServerStatus;

using StringTools;

// @todo: Not ready yet
class PhpServer implements Server {
	final factory:PhpRequestFactory;

	public function new(?factory:PhpRequestFactory) {
		this.factory = factory ?? new PhpRequestFromSuperGlobals();
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		return new Future(activate -> {
			handler.process(factory.createRequest()).handle(response -> {
				Syntax.code('http_response_code({0})', response.status);

				for (header in response.getHeaders()) {
					Global.header('${header.name}:${header.value}');
				}

				// @todo: pipe output to a stream?
				// @todo: Echoing this is a hack
				Global.echo(response.body.toString().or(''));

				activate(Running(_ -> {
					throw 'Cannot shut down PHP servers this way';
				}));
			});
		});
	}
}

interface PhpRequestFactory {
	public function createRequest():Request;
}

class PhpRequestFromSuperGlobals implements PhpRequestFactory {
	public function new() {}

	public function createRequest():Request {
		var method = Method.parse(SuperGlobal._SERVER['REQUEST_METHOD']).or(() -> Method.Get);
		var url:String = SuperGlobal._SERVER['REQUEST_URI'];
		var request = new Request(method, url, getHeadersFromSuperGlobal());

		// @todo: parse body! we really need some kind of stream implementation.

		return request;
	}
}

private function getHeadersFromSuperGlobal():Headers {
	if (Global.function_exists('getallheaders')) {
		var raw = Lib.hashOfAssociativeArray(Global.getallheaders());
		return new Headers(...[for (name => value in raw) new HeaderField(name, value)]);
	}

	var serverInfo = Lib.hashOfAssociativeArray(SuperGlobal._SERVER);
	var headers = new Headers();

	function add(name, value) {
		headers = headers.with(new HeaderField(name, value));
	}

	for (name => value in serverInfo) {
		var key = switch name {
			case 'CONTENT_TYPE' if (!serverInfo.exists('HTTP_CONTENT_TYPE')): 'Content-Type';
			case 'CONTENT_LENGTH' if (!serverInfo.exists('HTTP_CONTENT_LENGTH')): 'Content-Length';
			case 'CONTENT_MD5' if (!serverInfo.exists('HTTP_CONTENT_MD5')): 'Content-Md5';
			case _ if (name.substr(0, 5) == "HTTP_"): name.substr(5).replace('_', '-');
			case _: continue;
		}

		add(key, value);
	}

	if (!serverInfo.exists('HTTP_AUTHORIZATION')) {
		return headers;
	}

	if (serverInfo.exists('REDIRECT_HTTP_AUTHORIZATION')) {
		add('Authorization', serverInfo.get('REDIRECT_HTTP_AUTHORIZATION'));
	} else if (serverInfo.exists('PHP_AUTH_USER')) {
		var basic = serverInfo.exists('PHP_AUTH_PW') ? serverInfo.get('PHP_AUTH_PW') : '';
		add('Authorization', 'Basic ' + haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(serverInfo.get('PHP_AUTH_USER'))).toString() + ':$basic');
	} else if (serverInfo.exists('PHP_AUTH_DIGEST')) {
		add('Authorization', serverInfo.get('PHP_AUTH_DIGEST'));
	}

	return headers;
}
