import socket
import struct

FPGA_MAC = bytes.fromhex("02123456789a")

def mac_addr(b):
    return ":".join(f"{x:02x}" for x in b)

def ip_addr(b):
    return ".".join(str(x) for x in b)

s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(0x0003))
s.bind(("enp3s0", 0))

while True:
    frame = s.recv(2048)

    # Ethernet header
    dst_mac = frame[0:6]
    src_mac = frame[6:12]
    eth_type = int.from_bytes(frame[12:14], 'big')

    # Filter only frames coming from FPGA MAC
    if src_mac != FPGA_MAC:
        continue

    print("=" * 80)
    print("Frame Length      :", len(frame))
    print("Destination MAC   :", mac_addr(dst_mac))
    print("Source MAC        :", mac_addr(src_mac))
    print("EtherType         :", f"0x{eth_type:04X}")

    # Check IPv4
    if eth_type != 0x0800:
        print("Not an IPv4 packet")
        print("Raw Payload       :", frame[14:])
        continue

    # ---------------- IPv4 Header ----------------
    ip_start = 14
    ver_ihl = frame[ip_start]
    version = ver_ihl >> 4
    ihl = (ver_ihl & 0x0F) * 4   # IP header length in bytes

    protocol = frame[ip_start + 9]
    src_ip = frame[ip_start + 12: ip_start + 16]
    dst_ip = frame[ip_start + 16: ip_start + 20]

    print("IP Version        :", version)
    print("Source IP         :", ip_addr(src_ip))
    print("Destination IP    :", ip_addr(dst_ip))
    print("Protocol          :", protocol)

    # Check UDP
    if protocol != 17:
        print("Not a UDP packet")
        print("IP Payload        :", frame[ip_start + ihl:])
        continue

    # ---------------- UDP Header ----------------
    udp_start = ip_start + ihl
    src_port, dst_port, udp_len, udp_checksum = struct.unpack(
        "!HHHH", frame[udp_start:udp_start + 8]
    )

    data = frame[udp_start + 8: udp_start + udp_len]

    print("Source Port       :", src_port)
    print("Destination Port  :", dst_port)
    print("UDP Length        :", udp_len)
    print("UDP Checksum      :", f"0x{udp_checksum:04X}")

    print("UDP Data (hex)    :", data.hex())
    try:
        print("UDP Data (ascii)  :", data.decode(errors="replace"))
    except:
        pass
