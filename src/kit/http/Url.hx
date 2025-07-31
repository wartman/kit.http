package kit.http;

import haxe.Exception;

using StringTools;

@:forward
abstract Url(UrlObject) from UrlObject {
	@:from public inline static function ofString(url:String):Url {
		return UrlObject.parse(url);
	}

	public function new(url:String) {
		this = UrlObject.parse(url);
	}

	@:to public function toString():String {
		return this.toString();
	}
}

class UrlObject {
	public static function parse(url:String):UrlObject {
		url = url.trim();

		var scheme = switch url.indexOf('://') {
			case -1: null;
			case index:
				var part = url.substring(0, index);
				url = url.substr(index + '://'.length);
				part;
		}

		var host = switch url.indexOf('/') {
			case -1:
				switch url.indexOf('?') {
					case -1:
						url;
					case index:
						url.substring(0, index);
				}
			case index:
				url.substring(0, index);
		}

		if (host.length == 0)
			host = null;
		else {
			url = url.substr(host.length);
		}

		var port = switch host?.indexOf(':') {
			case null | -1:
				null;
			case index:
				var port = host.substring(index + 1);
				host = host.substring(0, index);
				switch Std.parseInt(port) {
					case null: null; // @todo: Throw?
					case port: port;
				}
		}

		var path = '';

		if (!url.startsWith('?')) switch url.lastIndexOf('?') {
			case -1:
				switch url.indexOf('#') {
					case -1:
						path = url;
						url = '';
					case index:
						path = url.substring(0, index);
						url = url.substring(index);
				}
			case index:
				path = url.substring(0, index);
				url = url.substring(index);
		}

		var fragment = switch url.indexOf('#') {
			case -1: null;
			case index:
				var part = url.substring(index + 1);
				url = url.substring(0, index);
				part;
		}

		var query = switch url.indexOf('?') {
			case -1:
				new UrlQuery([]);
			case index:
				var part = url.substr(index + 1);
				url = '';
				UrlQuery.parse(part);
		}

		return new UrlObject(scheme, host, port, path, fragment, query);
	}

	public final scheme:Null<String>;
	public final host:Null<String>;
	public final port:Null<Int>;
	public final path:String;
	public final query:UrlQuery;
	public final fragment:Null<String>;

	public function new(scheme, host, port, path, fragment, query) {
		this.scheme = scheme;
		this.host = host;
		this.port = port;
		this.path = path;
		this.fragment = fragment;
		this.query = query;
	}

	public function withScheme(newScheme):Url {
		return new UrlObject(newScheme, host, port, path, fragment, query);
	}

	public function withHost(newHost):Url {
		return new UrlObject(scheme, newHost, port, path, fragment, query);
	}

	public function withPort(newPort):Url {
		return new UrlObject(scheme, host, newPort, path, fragment, query);
	}

	public function withPath(newPath):Url {
		return new UrlObject(scheme, host, port, newPath, fragment, query);
	}

	public function withFragment(newFragment):Url {
		return new UrlObject(scheme, host, port, path, newFragment, query);
	}

	public function withoutQuery():Url {
		return new UrlObject(scheme, host, port, path, fragment, new UrlQuery([]));
	}

	public function withQueryParam(key, value):Url {
		return new UrlObject(scheme, host, port, path, fragment, query.with(key, value));
	}

	public function withoutQueryParam(key):Url {
		return new UrlObject(scheme, host, port, path, fragment, query.without(key));
	}

	public function toString():String {
		var buffer = new StringBuf();
		if (scheme != null) {
			buffer.add(scheme);
			buffer.add('://');
		}

		if (host != null) {
			buffer.add(host);
		}

		if (port != null) {
			buffer.add(':$port');
		}

		if (path.length > 0) {
			if (!path.startsWith('/')) buffer.add('/');
			buffer.add(path);
		}

		var q = query.toString();
		if (q.length > 0) {
			buffer.add('?');
			buffer.add(q);
		}

		if (fragment != null) {
			buffer.add('#');
			buffer.add(fragment);
		}

		return buffer.toString();
	}
}

@:forward(get, exists, iterator, keyValueIterator)
abstract UrlQuery(Map<String, String>) {
	@:from public static function parse(query:String):UrlQuery {
		var params:Map<String, String> = [];
		var parts = query.split('&');

		for (param in parts) switch param.split('=') {
			case [key, value]: params.set(key.trim(), value.trim().urlDecode());
			default: throw new Exception('Malformed url');
		}

		return new UrlQuery(params);
	}

	public function new(params) {
		this = params;
	}

	public function with(key, value) {
		var params = this.copy();
		params.set(key, value);
		return new UrlQuery(params);
	}

	public function without(key) {
		var params = this.copy();
		params.remove(key);
		return new UrlQuery(params);
	}

	public function toString() {
		return [for (key => value in this) '$key=${value.urlEncode()}'].join('&');
	}
}
