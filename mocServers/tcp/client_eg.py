import socket
import time

def read_d10_from_plc():
    server_ip = '127.0.0.1'
    port = 502

    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((server_ip, port))
            print(f"Connected to PLC at {server_ip}:{port}")

            while True:
                # Send request to read D10
                s.sendall(b"READ D10")

                # Receive the data from the server
                data = s.recv(1024)
                if data:
                    print(f"Received from PLC: {data.decode()}")
                else:
                    print("Connection closed by server")
                    break

                # Wait for some time before requesting again
                time.sleep(10)  # Adjust delay to match server's update rate
    except ConnectionError:
        print("Connection error. Could not connect to the PLC.")
    except KeyboardInterrupt:
        print("Client disconnected.")

if __name__ == "__main__":
    read_d10_from_plc()


#  below code connects to server, read the current value and disconnects
# import socket

# def read_d10_from_plc():
#     server_ip = '127.0.0.1'
#     port = 502

#     with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
#         s.connect((server_ip, port))
#         s.sendall(b"READ D10")
#         data = s.recv(1024)
#         print(f"Received from PLC: {data.decode()}")

# if __name__ == "__main__":
#     read_d10_from_plc()
