import os
import sys
import zipfile
import json
import xml.etree.ElementTree as ET

# Ensure utf-8 output on Windows terminal
sys.stdout.reconfigure(encoding='utf-8')

raw_dir = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
files = sorted(os.listdir(raw_dir))

print("=== ZIP ARCHIVE SUMMARIES ===")
for f in files:
    if f.endswith(".zip"):
        zip_path = os.path.join(raw_dir, f)
        print(f"\nArchive: {f} ({os.path.getsize(zip_path)/(1024*1024):.2f} MB)")
        try:
            with zipfile.ZipFile(zip_path, 'r') as z:
                names = z.namelist()
                print(f"  Total items: {len(names)}")
                # Show top 5 items
                for n in names[:5]:
                    print(f"   - {n}")
                if len(names) > 5:
                    print(f"   ... and {len(names) - 5} more")
        except Exception as e:
            print(f"  Error: {e}")

print("\n=== DOCX SUMMARIES ===")
for f in files:
    if f.endswith(".docx"):
        docx_path = os.path.join(raw_dir, f)
        print(f"\nDocument: {f} ({os.path.getsize(docx_path)/(1024*1024):.2f} MB)")
        try:
            with zipfile.ZipFile(docx_path, 'r') as z:
                xml_content = z.read('word/document.xml')
                tree = ET.fromstring(xml_content)
                paragraphs = []
                for p in tree.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
                    texts = [t.text for t in p.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t') if t.text]
                    if texts:
                        paragraphs.append("".join(texts))
                print(f"  Total non-empty paragraphs: {len(paragraphs)}")
                print(f"  Total character count: {sum(len(p) for paragraphs in paragraphs for p in [paragraphs])}")
                print(f"  Sample text:\n    " + "\n    ".join(paragraphs[:8]))
        except Exception as e:
            print(f"  Error: {e}")

