import urllib.request
import re

url = 'https://www.facebook.com/share/v/1Gj4SquVrX/'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8', errors='ignore')
    match = re.search(r'"playable_url":"([^"]+)"', html)
    if match:
        video_url = match.group(1).encode().decode('unicode-escape')
        print(f'Found video url: {video_url}')
    else:
        print('Playable url not found')
except Exception as e:
    print(f'Error: {e}')
