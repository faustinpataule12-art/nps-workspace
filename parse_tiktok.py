import urllib.request, re
url = 'https://www.tiktok.com/@swedernps'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    title = re.findall(r'<title>(.*?)</title>', html)
    desc = re.findall(r'<meta name="description" content="(.*?)"', html)
    og_desc = re.findall(r'<meta property="og:description" content="(.*?)"', html)
    print('Titre:', title[0] if title else 'Non trouvé')
    print('Description:', desc[0] if desc else (og_desc[0] if og_desc else 'Non trouvée'))
except Exception as e:
    print('Erreur:', str(e))
