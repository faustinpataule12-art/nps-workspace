import urllib.request
import re

url = 'https://www.facebook.com/share/v/1Gj4SquVrX/'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8', errors='ignore')
    matches = re.findall(r'<meta property="og:video" content="([^"]+)"', html)
    if matches:
        print('Video URL:', matches[0])
    else:
        print('Aucune balise og:video trouvee')
except Exception as e:
    print('Erreur:', e)
