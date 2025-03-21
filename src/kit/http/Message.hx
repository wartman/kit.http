package kit.http;

// @todo: We need to handle body better.
abstract class Message<R:Message<R>> {
	public final body:Body;

	final headers:Headers;

	public function new(?headers, ?body:Body) {
		this.headers = headers == null ? new Headers() : headers;
		this.body = body ?? new Body();
	}

	abstract public function withHeader(header:HeaderField):R;

	abstract public function withoutHeader(header:HeaderName):R;

	public function getHeaders() {
		return headers.clone();
	}

	public function getHeader(header:HeaderName):Result<HeaderField> {
		return switch headers.get(header) {
			case [field]: Ok(field);
			case []: Error(new Error(NotFound, 'No header named $header exists'));
			default: Error(new Error(InternalError, 'Multiple entries for $header found'));
		}
	}

	abstract public function withBody(body:Body):R;
}
