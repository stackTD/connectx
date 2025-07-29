import socket
import threading
import random
import time

# Mock PLC Server class
class MockPLCServer:
    def __init__(self, host='127.0.0.1', port=502):
        self.host = host
        self.port = port
        self.registers = {
            'D10': {'value': 0, 'min': 1, 'max': 30},
            'D20': {'value': 0, 'min': 35, 'max': 65},
            'D30': {'value': 0, 'min': 70, 'max': 100},
            'D40': {'value': 0, 'min': 1, 'max': 100},
            'D50': {'value': 0, 'min': 1, 'max': 100},
            'D60': {'value': 0, 'min': 1, 'max': 100},
        }
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.is_running = False

    def start_server(self):
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen()
        print(f"TCP/IP PLC available @  {self.host}:{self.port}")
        self.is_running = True

        # Start thread to update D10 value
        threading.Thread(target=self.update_registers, daemon=True).start()

        while self.is_running:
            client_socket, client_address = self.server_socket.accept()
            print(f"Connection from {client_address}")
            threading.Thread(target=self.handle_client, args=(client_socket,), daemon=True).start()

    def stop_server(self):
        self.is_running = False
        self.server_socket.close()

    def update_registers(self):
        while self.is_running:
            for register, config in self.registers.items():
                self.registers[register]['value'] = random.randint(config['min'], config['max'])
                print(f"Updated {register}: {self.registers[register]['value']}")
            time.sleep(1) 

    def handle_client(self, client_socket):
        try:
            while self.is_running:
                try:
                    # Receive the request
                    request = client_socket.recv(1024).decode().strip()
                    print(f"Received request: {request}")
                    if request in self.registers:
                        # Send the register value as response
                        response = str(self.registers[request]['value'])
                        print(f"Sending response: {response}")
                        client_socket.send(f"{request}:{response}\n".encode())
                    else:
                        print(f"Invalid register request: {request}")
                        client_socket.send("Invalid register\n".encode())
                        
                except socket.error:
                    break
                
        finally:
            print("Client disconnected")
            client_socket.close()


     
            
if __name__ == "__main__":
    # Start the mock PLC server
    plc_server = MockPLCServer(host='127.0.0.1', port=502)
    try:
        plc_server.start_server()
    except KeyboardInterrupt:
        plc_server.stop_server()
        print("Mock PLC server stopped.")
