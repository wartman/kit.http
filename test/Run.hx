import kit.http.*;

using kit.Testing;

function main() {
	Runner.fromDefaults('Kit Http')
		.add(HandlerSuite)
		.add(UrlSuite)
		#if (nodejs)
			.add(kit.http.server.NodeServerSuite)
		#end
		.run();
}
