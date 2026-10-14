import urllib.request, re
url = 'https://vm.tiktok.com/ZSgeNfeNL/'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    match = re.search(r'"playAddr":"([^"]+)"', html)
    if match:
        print('Lien direct trouvé:', match.group(1).replace('\\u002F', '/'))
    else:
        print('Page accessible mais lien direct protégé par les scripts dynamiques de TikTok.')
except Exception as e:
    print('Erreur:', e)
