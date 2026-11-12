from pathlib import Path
import json,re,subprocess,hashlib
root=Path(__file__).resolve().parents[1];m=json.loads((root/'Tools/translation-map.json').read_text())
for k,v in m.items():
 assert k.count('%@')==v.count('%@'),(k,v)
 assert v,(k,v)
for lang in ['en','zh-Hans']:
 subprocess.run(['plutil','-lint',str(root/f'Sources/Wattson/Resources/{lang}.lproj/Localizable.strings')],check=True)
print(f'{len(m)} entries: matching keys, placeholders and valid property lists')
# The reader and algorithm sources must remain byte-identical to upstream.
protected=['PowerMonitor','SMCMonitor','PortMonitor','SourceCapabilities','Scanner','BOSDescriptor','ThrottleMonitor','DeviceModel','Models','CableLimit','LinkBottleneck','PhyMonitor','ThunderboltMonitor','DisplayMonitor','Volumes','PortStats','ConnectionLog','SelfTest','JSONOutput']
manifest=json.loads((root/'Tools/upstream-source-hashes.json').read_text())
for name in protected:
 p=f'Sources/Wattson/{name}.swift'
 assert hashlib.sha256((root/p).read_bytes()).hexdigest()==manifest[p],p
print(f'{len(protected)} reader/model/algorithm files unchanged from the audited upstream baseline')
