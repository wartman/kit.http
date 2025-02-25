import kit.http.*;
import kit.http.server.*;

using Kit;
using StringTools;

function main() {
	var handler = new Handler(request -> new Future(activate -> {
		var headers = new Headers({name: ContentType, value: 'text/html'});
		var res = new Response(NotFound, headers, '<p>Not Found</p>');
		activate(res);
	})).into(new HelloWorldMiddleware());

	#if nodejs
	var server = new NodeServer(8080);
	#elseif php
	var server = new PhpServer();
	#else
	var server = new MockServer(response -> {
		trace(response.body.map(body -> body.toString()).or('<p>No body</p>'));
	});
	#end

	server.serve(handler).handle(mode -> switch mode {
		case Failed(e): trace(e);
		case Running(close): // todo
		case Closed: trace('closed');
	});
}

class HelloWorldMiddleware implements Middleware {
	public function new() {}

	public function apply(handler:Handler):Handler {
		return request -> {
			if (!request.url.path.startsWith('/hello')) return handler.process(request);
			var headers = new Headers(new HeaderField(ContentType, 'text/html'));
			var res = new Response(OK, headers, '<p>Hello ${request.url}</p>');
			return Future.immediate(res);
		};
	}
}
