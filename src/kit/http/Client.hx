package kit.http;

interface Client {
	public function request(request:Request):Task<Response>;
}
