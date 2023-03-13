package kit.http;

import haxe.io.Bytes;

abstract class Message<R:Message<R>> {
	public final headers:Headers;
	public final body:Maybe<Bytes>; // @todo: Make body a Stream?

	public function new(?headers, ?body) {
		this.headers = headers == null ? new Headers([]) : headers;
		this.body = body == null ? None : Some(body);
	}

	abstract public function withHeader(header:HeaderField):R;

	abstract public function withBody(body:Bytes):R;
}
