import haxe.io.Bytes;
import kit.http.*;
import kit.http.server.NodeServer;

using Kit;
using StringTools;

function main() {
	var handler = new Handler(request -> new Future(activate -> {
		var headers = new Headers([{name: ContentType, value: 'text/html'}]);
		var res = new Response(NotFound, headers, Bytes.ofString('<p>Not Found</p>'));
		activate(res);
	})).into(new HelloWorldMiddleware());

	var server = new NodeServer(8080);
	server.serve(handler).handle(mode -> switch mode {
		case Failed(e): trace(e);
		case Running(close): // todo
		case Closed: trace('closed');
	});
}

class HelloWorldMiddleware implements Middleware {
	public function new() {}

	public function apply(handler:Handler):Handler {
		return new Handler(request -> {
			if (!request.url.path.startsWith('/hello')) return handler.process(request);
			var headers = new Headers([{name: ContentType, value: 'text/html'}]);
			var res = new Response(OK, headers, Bytes.ofString('<p>Hello ${request.url}</p>'));
			return Future.immediate(res);
		});
	}
}
