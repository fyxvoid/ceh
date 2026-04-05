from http.server import HTTPServer, SimpleHTTPRequestHandler
import subprocess, json, threading

class Handler(SimpleHTTPRequestHandler):

    def do_POST(self):
        if self.path == "/run-scan":
            def run():
                subprocess.run(["sudo", "bash", "watcher.sh", "eth0", "24"])
            threading.Thread(target=run).start()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"success": True}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # suppress server logs

print("[*] Dashboard running at http://localhost:8080")
HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
