#!/usr/bin/env python3
import sys
import os
import re
import json
import urllib.request
import urllib.parse

CACHE_DIR = os.path.expanduser("~/.local/share/nebuladeck/banners")
os.makedirs(CACHE_DIR, exist_ok=True)
LEGACY_CACHE_DIR = os.path.expanduser("~/.local/share/plasma-deck-launcher/banners")

def sanitize_filename(name):
    return re.sub(r'[^a-zA-Z0-9_-]', '_', name).strip('_').lower()

def fetch_steam_banner(query):
    try:
        # Search Steam Store public API (used by Steam Deck / Bazzite)
        encoded_query = urllib.parse.quote(query)
        search_url = f"https://store.steampowered.com/api/storesearch/?term={encoded_query}&l=english&cc=US"
        req = urllib.request.Request(search_url, headers={'User-Agent': 'Mozilla/5.0 (Linux; NebulaDeck)'})
        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode('utf-8'))
            if data.get('total', 0) > 0 and len(data.get('items', [])) > 0:
                app_id = data['items'][0]['id']
                # High quality Steam Library Hero or Header
                hero_url = f"https://cdn.cloudflare.steamstatic.com/steam/apps/{app_id}/library_hero.jpg"
                header_url = f"https://cdn.cloudflare.steamstatic.com/steam/apps/{app_id}/header.jpg"
                
                try:
                    h_req = urllib.request.Request(hero_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(h_req, timeout=3) as h_res:
                        if h_res.status == 200:
                            return hero_url
                except Exception:
                    pass
                return header_url
    except Exception:
        pass
    return None

def fetch_flathub_media(query):
    try:
        # Search Flathub API for Linux native games & apps (Spotube, Dolphin, SuperTuxKart, etc.)
        encoded_query = urllib.parse.quote(query)
        url = f"https://flathub.org/api/v2/search?query={encoded_query}"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (PlasmaDeckLauncher)'})
        with urllib.request.urlopen(req, timeout=4) as response:
            data = json.loads(response.read().decode('utf-8'))
            hits = data.get('hits', [])
            if hits and len(hits) > 0:
                app = hits[0]
                screenshots = app.get('screenshots', [])
                if screenshots and len(screenshots) > 0:
                    for sc in screenshots:
                        img = sc.get('img_desktop') or sc.get('img_mobile') or sc.get('src')
                        if img:
                            return img
    except Exception:
        pass
    return None

def download_and_cache(app_name):
    clean_name = sanitize_filename(app_name)
    if not clean_name:
        print("")
        return ""
        
    cached_path = os.path.join(CACHE_DIR, f"{clean_name}.jpg")
    
    if os.path.exists(cached_path) and os.path.getsize(cached_path) > 1000:
        print(cached_path)
        return cached_path

    banner_url = fetch_steam_banner(app_name)
    if not banner_url:
        banner_url = fetch_flathub_media(app_name)

    if banner_url:
        try:
            req = urllib.request.Request(banner_url, headers={'User-Agent': 'Mozilla/5.0 (Linux; SteamOS)'})
            with urllib.request.urlopen(req, timeout=6) as response, open(cached_path, 'wb') as out_file:
                out_file.write(response.read())
            print(cached_path)
            return cached_path
        except Exception:
            pass

    print("")
    return ""

if __name__ == "__main__":
    if len(sys.argv) > 1:
        app_name = " ".join(sys.argv[1:])
        download_and_cache(app_name)
    else:
        print("")
