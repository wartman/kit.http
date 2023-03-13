import Kit.Future;
import haxe.io.Bytes;
import kit.http.*;
import kit.http.adaptor.NodeAdaptor;

function main() {
	var server = new Server((request:Request) -> {
		return new Future(activate -> {
			var res = new Response(404, new Headers([{name: ContentType, value: 'text/html'}]), Bytes.ofString('<p>Not Found</p>'));
			activate(res);
		});
	});
	server.apply(new HelloWorldMiddleware());
	server.serve(new NodeAdaptor(8080)).handle(mode -> switch mode {
		case Failed(e): trace(e);
		case Running(close): // todo
		case Closed: trace('closed');
	});
}

class HelloWorldMiddleware implements Middleware {
	public function new() {}

	public function apply(handler:Handler):Handler {
		return new Handler(request -> {
			return new Future(activate -> {
				var res = new Response(200, new Headers([{name: ContentType, value: 'text/html'}]), Bytes.ofString('<p>Hello ${request.url}</p>'));
				activate(res);
			});
		});
	}
}
