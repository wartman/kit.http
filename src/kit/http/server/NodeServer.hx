package kit.http.server;

import haxe.io.Bytes;
import js.lib.Uint8Array;
import js.node.http.*;
import kit.http.Server;

using Kit;
using kit.Sugar;

private enum ServerInitObject {
	Instance(server:js.node.net.Server);
	Port(port:Int);
	Url(url:Url);
}

abstract ServerInit(ServerInitObject) from ServerInitObject to ServerInitObject {
	@:from public static function ofInstance(server:js.node.net.Server):ServerInit {
		return Instance(server);
	}

	@:from public static function ofString(path:String):ServerInit {
		return Url(path);
	}

	@:from public static function ofUrl(url:Url):ServerInit {
		return Url(url);
	}

	@:from public static function ofPort(port:Int):ServerInit {
		return Port(port);
	}
}

class NodeServer implements Server {
	final init:ServerInitObject;

	public function new(init:ServerInit) {
		this.init = init;
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		var nodeServer = switch init {
			case Instance(server):
				server;
			case Port(port):
				var server = new js.node.http.Server();
				server.listen(port);
				server;
			case Url(url):
				var server = new js.node.http.Server();
				server.listen(url.toString());
				server;
		}

		return new Future(activate -> {
			nodeServer.on('error', e -> {
				activate(Failed(e));
			});
			nodeServer.on('listening', () -> {
				activate(Running((finish) -> nodeServer.close(() -> finish(true))));
			});
			nodeServer.on('request', (req:IncomingMessage, res:ServerResponse) -> {
				var method:kit.http.Method = switch req.method {
					case Post: Post;
					case Patch: Patch;
					case Delete: Delete;
					default: Get;
				};
				var headers:Headers = [for (key => value in req.headers) {name: key, value: value}];
				var request = new Request(method, req.url, headers);

				// @todo: Handle the upload stream better
				Stream.ofNodeReadable(req)
					.reduce(request, (request, chunk) -> request.withBody(request.body.or(() -> Body.empty()).with(Bytes.ofString('' + chunk))))
					.recover(_ -> Future.immediate(new Request(method, req.url, headers))) // @todo: actually handle this
					.handle(request -> {
						handler.process(request).handle(response -> {
							var headers:Map<String, Array<String>> = [];
							for (header in response.headers) {
								if (!headers.exists(header.name)) headers.set(header.name, []);
								headers.get(header.name).push(header.value);
							}
							for (name => values in headers) {
								res.setHeader(name, values);
							}
							res.writeHead(response.status);

							switch response.body {
								case None:
									res.end();
								case Some(body):
									body.each(item -> {
										var buf = new Uint8Array(item.getData(), 0, item.length);
										res.write(buf);
									}).handle(result -> switch result {
										case Depleted: res.end();
										case Errored(error):
											// @todo: handle error?
											res.end();
										default:
											// @todo: Send an error?
											res.end();
									});
							}
						});
					});
			});
		}).eager();
	}
}
