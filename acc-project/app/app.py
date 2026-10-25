from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os
import time

STARTED_AT = time.time()

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = {"status": "ok", "uptime_seconds": int(time.time() - STARTED_AT)}
            payload = json.dumps(body).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return
        payload = b"ACC Cloud Reliability Demo - service is running\nTry GET /health\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    print(f"Starting demo service on port {port}", flush=True)
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()
