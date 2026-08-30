#!/usr/bin/env python3
import json, os

data = {
    "kernel": os.uname().release,
    "os": "postmarketOS Linux",
    "ram": "8 GB LPDDR5",
    "cpu": "Qualcomm Snapdragon 870 5G (8 Cores @ 3.2 GHz)",
    "gpu": "Qualcomm Adreno 650 • turnip Mesa 26.1.6 (Vulkan 1.3 / OpenGL 4.6)",
    "kde": "KDE Plasma 6 (Wayland)",
    "proton": "FEX-Emu / Box64 • Proton 9 / Wine Gaming Layer"
}

try:
    with open("/etc/os-release") as f:
        for line in f:
            if line.startswith("PRETTY_NAME="):
                data["os"] = line.split("=", 1)[1].strip().strip('"')
except Exception:
    pass

try:
    with open("/proc/meminfo") as f:
        for line in f:
            if line.startswith("MemTotal:"):
                kb = int(line.split()[1])
                data["ram"] = f"{kb/1024/1024:.1f} GB LPDDR5"
except Exception:
    pass

try:
    cpu_cores = os.cpu_count() or 8
    data["cpu"] = f"Qualcomm Snapdragon 870 ({cpu_cores} Cores @ 3.2 GHz)"
except Exception:
    pass

print(json.dumps(data))
