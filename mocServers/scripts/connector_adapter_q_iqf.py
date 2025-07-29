import pymcprotocol


class PLCConnector:
    def __init__(self):
        self.pymc3e = None

    def connect_to_plc(self, ip_address, port_number):
        try:
            print(f"PLC_connect: Connecting to PLC at {ip_address}:{port_number}")
            self.pymc3e = pymcprotocol.Type3E(plctype="Q")  # Update the PLC as needed
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


class PLCAdapter:
    def __init__(self, plc_connector):
        self.plc_connector = plc_connector

    def read_string_register(self, location, registers):
        """
        Read string data from PLC registers
        location: Starting address (e.g., 'D100')
        registers: Number of registers to read
        """
        try:
            if not self.plc_connector.pymc3e:
                print("Error: PLC not connected")
                return None
            
            decimal_numbers = self.plc_connector.pymc3e.batchread_wordunits(headdevice=location, readsize=registers)
            print(f"Decimal Numbers: {decimal_numbers}")
            
            # Convert decimal numbers to ASCII characters
            ascii_string = ''
            for num in decimal_numbers:
                # Each word contains 2 ASCII characters
                high_byte = num >> 8
                low_byte = num & 0xFF
                ascii_string += chr(high_byte) + chr(low_byte)
            
            return ascii_string.strip('\x00')  # Remove null characters
        except Exception as e:
            print(f"Error reading from PLC: {e}")
            return None

    def read_word_registers(self, location, registers):
        """
        Read numeric data from PLC registers
        location: Starting address (e.g., 'D100')
        registers: Number of registers to read
        """
        try:
            if not self.plc_connector.pymc3e:
                print("Error: PLC not connected")
                return None
            
            values = self.plc_connector.pymc3e.batchread_wordunits(headdevice=location, readsize=registers)
            return values
        except Exception as e:
            print(f"Error reading from PLC: {e}")
            return None


if __name__ == "__main__":
    ip_address = input("Enter PLC IP address: ")
    port_number = int(input("Enter PLC port number: "))


    # Create and connect PLC connector
    plc_connector = PLCConnector()
    if plc_connector.connect_to_plc(ip_address, port_number):
        # Create PLC adapter
        plc_adapter = PLCAdapter(plc_connector)
        
        try:
            while True:
            # Example: Read 10 registers starting from D100
                choice = input("Press 1 to read word registers or 2 to read string registers: ")
                location = input("Enter the starting register address (e.g., 'D100'): ")
                batch_size = int(input("Enter the number of registers to read: "))

                if choice == '1':
                    print("\nReading word registers...")
                    word_data = plc_adapter.read_word_registers(location, batch_size)
                    print(f"Word data: {word_data}")
                elif choice == '2':
                    print("\nReading string registers...")
                    string_data = plc_adapter.read_string_register(location, batch_size)
                    print(f"String data: {string_data}")
                else:
                    print("Invalid choice")
                
                next_action = input("Press 1 to read data again or 2 to disconnect: ")
                if next_action == '2':
                    break
            
        except Exception as e:
            print(f"Error during operation: {e}")
        finally:
            input("\nPress Enter to disconnect...")
            plc_connector.disconnect_from_plc()