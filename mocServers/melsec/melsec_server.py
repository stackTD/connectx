import socket
import struct
import threading
import random
import time

class MockMelsecPLC:
    def __init__(self, host="localhost", port=5000):
        self.host = host
        self.port = port
        self.d20_value = random.randint(1, 99)
        self.is_running = True
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    def start_server(self):
        try:
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(1)
            print(f"Mock MELSEC PLC Server running on {self.host}:{self.port}")
            threading.Thread(target=self.update_d20_value, daemon=True).start()  # Start D20 updater thread
            while self.is_running:
                client_socket, client_address = self.server_socket.accept()
                print(f"Connected by {client_address}")
                self.handle_client(client_socket)
        except Exception as e:
            print(f"Error starting server: {e}")
        finally:
            self.server_socket.close()

    def update_d20_value(self):
        """Update D20 register value every 10 seconds."""
        while self.is_running:
            time.sleep(10)
            self.d20_value = random.randint(1, 99)
            print(f"Updated D20 value: {self.d20_value}")

    def handle_client(self, client_socket):
        try:
            while True:
                # Receive request from the client
                request = client_socket.recv(1024)
                if not request:
                    break

                # Parse the request (assumed to be binary format)
                response = self.process_mc_request(request)
                
                # Send the response back to the client
                client_socket.send(response)
        except Exception as e:
            print(f"Error handling client: {e}")
        finally:
            client_socket.close()
            print("Client disconnected")

    def process_mc_request(self, request):
        """Process the MC protocol request and generate a response."""
        try:
            # Unpack the header and command from the request
            # For simplicity, we assume that it's a read request for D register in binary mode
            # A real MC protocol has more structure, but we'll mock just the essential behavior
            command = request[0:2]  # Extract command (simplified)
            subcommand = request[2:4]  # Extract subcommand (simplified)

            # We are only processing a read request for D20 (Device D register)
            if command == b'\x00\x04' and subcommand == b'\x00\x00':
                # This simulates a "read word" command for device register
                # Respond with the current value of D20 (as a binary response)
                d20_value = self.d20_value
                response = struct.pack('<H', d20_value)  # Pack the value as a little-endian 16-bit integer
                return response
            else:
                # Return an error response (simplified)
                return b'\x00\x00'  # Just a basic placeholder for error
        except Exception as e:
            print(f"Error processing request: {e}")
            return b'\x00\x00'  # Return an empty response if parsing fails

    def stop_server(self):
        self.is_running = False
        self.server_socket.close()

if __name__ == "__main__":
    plc = MockMelsecPLC(host="localhost", port=5000)
    try:
        plc.start_server()
    except KeyboardInterrupt:
        plc.stop_server()
        print("Mock MELSEC PLC Server stopped.")
