import json
import threading
import unittest
from http.server import HTTPServer
from urllib.request import urlopen

from app import Handler


class HealthEndpointTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = HTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base_url = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=2)

    def test_health_endpoint_returns_ok_json(self):
        with urlopen(f"{self.base_url}/health", timeout=3) as response:
            payload = json.loads(response.read().decode("utf-8"))
            self.assertEqual(response.status, 200)
            self.assertEqual(payload["status"], "ok")
            self.assertIsInstance(payload["uptime_seconds"], int)
            self.assertGreaterEqual(payload["uptime_seconds"], 0)

    def test_home_endpoint_returns_project_message(self):
        with urlopen(f"{self.base_url}/", timeout=3) as response:
            body = response.read().decode("utf-8")
            self.assertEqual(response.status, 200)
            self.assertIn("ACC Azure Cloud Reliability Demo", body)
            self.assertIn("/health", body)


if __name__ == "__main__":
    unittest.main()
