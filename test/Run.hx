import kit.http.*;

using kit.Testing;

function main() {
	Runner.fromDefaults('Kit Http').add(HandlerSuite).run();
}
