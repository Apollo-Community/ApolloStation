from urllib.request import build_opener
from bs4 import BeautifulSoup
from sys import argv

url = str(argv[1])
url = "https://apollo-community.org/wiki/index.php?title=Example_Paperwork"
resource

try:
    from urllib.request import build_opener as opener
    opener = build_opener()
    opener.addheaders = [('User-agent', 'Mozilla/5.0')] #wikipedia needs this
    resource = opener.open(url)
except ImportError:
    print("urllib request build_opener not imported")
    
try:
    from urllib.request import urlopen
    req = Request(url, headers={'User-Agent' : "Mozilla/5.0"}) 
    resource = opener( req )
except ImportError:
    print("urllib request urlopen not imported")

data = resource.read()
resource.close()
soup = BeautifulSoup(data, "html.parser")
data = soup.find('div',id="mw-content-text")

#Some preprocessing becuase byond is crap with html chars
data_string = str(data)
data_lines = list(data_string.splitlines(True))

#If pulled data is empty exit with 1 so the shell knows it failed
if len(data_lines) == 0:
    exit(1)
i = 0
while i < len(data_lines):
    if '<div class="mw-collapsible-content"><pre>' in data_lines[i]:
        data_lines[i] = "\n--start--\n"

    if "</pre></div></div>" in data_lines[i]:
        data_lines[i] = "\n--stop--"
        
    if "<" in data_lines[i] or ">" in data_lines[i]:
        data_lines[i] = ""
        
    i += 1

data_string = str(" ".join(str(x) for x in data_lines))
text_file = open("scripts/wikiForms.txt", "w", encoding='utf-8')
text_file.write(data_string)
text_file.close()
exit()
