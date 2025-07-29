import pymcprotocol


class PLCConnector:
    def __init__(self):
        self.pymc3e = None

    def connect_to_plc(self, ip_address, port_number):
        try:
            print(f"PLC_connect: Connecting to PLC at {ip_address}:{port_number}")
            self.pymc3e = pymcprotocol.Type3E(plctype="Q")  # changed from IQ-R to IQ-Q
            self.pymc3e.setaccessopt(commtype="binary")
            self.pymc3e.connect(ip_address, port_number)
            print("Connected to PLC successfully")
            return True
        except Exception as e:
            print(f"PLC_Connect: Failed to connect to PLC: {e}")
            return False

    def disconnect_from_plc(self):
        try:
            if self.pymc3e:
                self.pymc3e.close()
                self.pymc3e = None
                print("Disconnected from PLC")
                return True
            else:
                print("PLC not connected")
                return False
        except Exception as e:
            print(f"Failed to disconnect from PLC: {e}")
            return False


# class PLCAdapter:


if __name__ == "__main__":
    ip_address = input("Enter PLC IP address: ")
    port_number = int(input("Enter PLC port number: "))

    plc_connector = PLCConnector()
    if plc_connector.connect_to_plc(ip_address, port_number):
        input("Press Enter to disconnect...")
        plc_connector.disconnect_from_plc()
