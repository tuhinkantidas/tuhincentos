from http.server import BaseHTTPRequestHandler, HTTPServer
import json, os, time
STARTED = time.time()
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = json.dumps({"status":"ok","uptime_seconds":int(time.time()-STARTED)}).encode()
            self.send_response(200); self.send_header("Content-Type","application/json")
            self.send_header("Content-Length",str(len(body))); self.end_headers(); self.wfile.write(body)
        else:
            body = b"ACC Azure Cloud Reliability Demo\nEndpoint: /health\n"
            self.send_response(200); self.send_header("Content-Type","text/plain; charset=utf-8")
            self.send_header("Content-Length",str(len(body))); self.end_headers(); self.wfile.write(body)
    def log_message(self, fmt, *args): print("%s - %s"%(self.address_string(),fmt%args),flush=True)
if __name__ == "__main__":
    port=int(os.getenv("PORT","8080")); print(f"Starting service on {port}",flush=True)
    HTTPServer(("0.0.0.0",port),Handler).serve_forever()
