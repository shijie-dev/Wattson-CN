from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]
m={}
for line in (root/'Tools/translations.txt').read_text().splitlines():
 if '|' in line:
  a,b=line.split('|',1);m[a]=b
m.update(json.loads((root/"Tools/extra-translations.json").read_text()))
# Normalize runtime format keys to object placeholders; captured numbers keep their original precision/sign.
fmt=re.compile(r'%(?:\d+\$)?[+\-0 #]*\d*(?:\.\d+)?[df@]')
m={fmt.sub('%@',k):fmt.sub('%@',v) for k,v in m.items()}
res=root/'Sources/Wattson/Resources'
for lang in ['en','zh-Hans']:
 p=res/(lang+'.lproj');p.mkdir(parents=True,exist_ok=True)
 (p/'Localizable.strings').write_text('\n'.join(json.dumps(k,ensure_ascii=False)+' = '+json.dumps(v if lang=='zh-Hans' else k,ensure_ascii=False)+';' for k,v in sorted(m.items()))+'\n')
(root/'Tools/translation-map.json').write_text(json.dumps(m,ensure_ascii=False,indent=2))
def sample(t):
    for i in range(t.count('%@')):
        t=t.replace('%@',f'__ARG{i}__',1)
    return t
(root/'Tools/localization-tests/catalog-cases.json').write_text(json.dumps([[sample(k),sample(v)] for k,v in m.items()],ensure_ascii=False))
