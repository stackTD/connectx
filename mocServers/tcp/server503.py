import socket
import threading
import random
import time

# Mock PLC Server class
class MockPLCServer:
    def __init__(self, host='127.0.0.1', port=503):
        self.host = host
        self.port = port
        self.registers = {'D10': 0}  # Define register D10
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.is_running = False

    def start_server(self):
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(1)
        print(f"TCP/IP PLC available @  {self.host}:{self.port}")
        self.is_running = True

        # Start thread to update D10 value
        threading.Thread(target=self.update_d10_value, daemon=True).start()

        while self.is_running:
            client_socket, client_address = self.server_socket.accept()
            print(f"Connection from {client_address}")
            threading.Thread(target=self.handle_client, args=(client_socket,), daemon=True).start()

    def stop_server(self):
        self.is_running = False
        self.server_socket.close()

    def update_d10_value(self):
        while self.is_running:
            self.registers['D10'] = random.randint(1, 99)
            print(f"Updated D10: {self.registers['D10']}")
            time.sleep(10)  # Update every 10 seconds

    def handle_client(self, client_socket):
        with client_socket:
            while self.is_running:
                # Simulate a request-response cycle for D10
                try:
                    data = client_socket.recv(1024)
                    if data:
                        request = data.decode()
                        print(f"Received request: {request}")
                        if request.strip().lower() == 'read d10':
                            # Respond with the current value of D10
                            response = f"D10={self.registers['D10']}"
                            client_socket.sendall(response.encode())
                        else:
                            client_socket.sendall(b"Unknown command")
                    else:
                        break
                except ConnectionError:
                    break
            print("Client disconnected")

if __name__ == "__main__":
    # Start the mock PLC server
    plc_server = MockPLCServer(host='127.0.0.1', port=503)
    try:
        plc_server.start_server()
    except KeyboardInterrupt:
        plc_server.stop_server()
        print("Mock PLC server stopped.")
