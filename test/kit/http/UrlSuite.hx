package kit.http;

class UrlSuite extends Suite {
	@:test(expects = 11)
	public function parsingWorks() {
		var url:Url = 'https://localhost:3000/test?foo=bar#other';
		url.scheme.equals('https');
		url.host.equals('localhost');
		url.port.equals(3000);
		url.path.equals('/test');
		url.query.get('foo').equals('bar');
		url.fragment.equals('other');
		url.toString().equals('https://localhost:3000/test?foo=bar#other');

		var url:Url = 'https://www.foobar.net/test/bar';
		url.scheme.equals('https');
		url.host.equals('www.foobar.net');
		url.path.equals('/test/bar');
		url.toString().equals('https://www.foobar.net/test/bar');
	}
}
