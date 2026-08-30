#!/usr/bin/env python3
import sys
import json
import urllib.request
import urllib.parse

def get_weather(city="Milano"):
    try:
        encoded_city = urllib.parse.quote(city)
        url = f"https://wttr.in/{encoded_city}?format=j1"
        req = urllib.request.Request(url, headers={'User-Agent': 'NebulaDeck/1.0 (Linux; Tablet)'})
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            print(json.dumps(data))
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    city = sys.argv[1] if len(sys.argv) > 1 else "Milano"
    get_weather(city)
