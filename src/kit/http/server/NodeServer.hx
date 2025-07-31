package kit.http.server;

import haxe.io.Bytes;
import js.lib.Uint8Array;
import js.node.http.*;
import kit.http.Server;

using kit.Sugar;

private enum ServerInitOptions {
	Instance(server:js.node.net.Server);
	Port(port:Int);
	Url(url:Url);
}

abstract ServerInit(ServerInitOptions) from ServerInitOptions to ServerInitOptions {
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
	final init:ServerInitOptions;

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
				var body = new Body();

				// @todo: Ideally we'll be using a stream here, but until that's ready we're just
				// waiting until the entire body is ready for a response. This means this library is
				// really not usable for any files that are remotely large.
				req.on('data', (chunk) -> {
					// Note: implicit conversion to string being done here.
					body.write(chunk + '');
				});

				req.on('end', () -> {
					handler.process(new Request(method, req.url, headers, body)).handle(response -> {
						var headers:Map<String, Array<String>> = [];
						for (header in response.getHeaders()) {
							if (!headers.exists(header.name)) headers.set(header.name, []);
							headers.get(header.name).push(header.value);
						}
						for (name => values in headers) {
							res.setHeader(name, values);
						}
						res.writeHead(response.status);
						// @todo: Again, if we had a stream implementation we'd use it here. Instead
						// we're just sending the whole dang thing for now.
						response.body.toBytes().extract(if (Some(bytes)) {
							var buf = new Uint8Array(bytes.getData(), 0, bytes.length);
							res.write(buf);
						});
						res.end();
					});
				});
			});
		}).eager();
	}
}
