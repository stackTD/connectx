import socket
import struct
import time

def connect_to_mock_plc(ip_address, port_number):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((ip_address, port_number))
            print(f"Connected to Mock MELSEC PLC at {ip_address}:{port_number}")

            while True:
                try:
                    # Create a "read word" command for D register, specifically D20 (binary mode)
                    # This is a simplified binary request
                    command = b'\x00\x04'  # "read word" command in binary
                    subcommand = b'\x00\x00'  # Subcommand (simplified)
                    s.sendall(command + subcommand)

                    # Receive the response
                    response = s.recv(1024)
                    
                    # Check if the server closed the connection
                    if not response:
                        print("Disconnected from PLC server")
                        break

                    # Unpack the received binary response (16-bit little-endian)
                    d20_value = struct.unpack('<H', response)[0]
                    print(f"Received D20 value from PLC: {d20_value}")

                    # Wait for a short period before the next read (e.g., 10 seconds)
                    time.sleep(10)

                except Exception as e:
                    print(f"Error while reading from PLC: {e}")
                    break
    except Exception as e:
        print(f"Failed to connect to Mock PLC: {e}")

if __name__ == "__main__":
    connect_to_mock_plc("localhost", 5000)
