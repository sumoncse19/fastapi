#!/usr/bin/env python3
"""
Simple HTTP server to serve the DailyBite web UI
"""
import http.server
import socketserver
import os
import webbrowser
from pathlib import Path

# Get the directory of this script
current_dir = Path(__file__).parent

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

if __name__ == "__main__":
    PORT = 3000
    
    # Change to the web UI directory
    os.chdir(current_dir)
    
    with socketserver.TCPServer(("", PORT), CORSHTTPRequestHandler) as httpd:
        print(f"🌐 DailyBite Web UI running at: http://localhost:{PORT}")
        print(f"📁 Serving files from: {current_dir}")
        print(f"🔗 Make sure your FastAPI backend is running at: http://localhost:8000")
        print("\n✨ Features available:")
        print("   • User registration and login")
        print("   • Photo upload for meal analysis")
        print("   • Daily calorie tracking")
        print("   • Progress visualization")
        print("\n🛑 Press Ctrl+C to stop the server")
        
        try:
            # Try to open browser automatically
            webbrowser.open(f'http://localhost:{PORT}')
        except:
            pass
            
        httpd.serve_forever()
