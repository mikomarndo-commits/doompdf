import pathlib
import json
import base64
import sys

import httpx
from lxml import html

html_path = pathlib.Path(sys.argv[1]).resolve()
out_path = pathlib.Path(sys.argv[2]).resolve()
html_str = html_path.read_text()

document = html.document_fromstring(html_str)

links = document.cssselect("link")
scripts = document.cssselect("script")
body = document.cssselect("body")[0]

def get_resource(url):
  if url.startswith("http"):
    response = httpx.get(url)
    response.raise_for_status()
    return response.content
  
  resource_path = html_path.parent / url
  return resource_path.read_bytes()

for link in links:
  href = link.get("href")
  rel = link.get("rel")
  if rel == "stylesheet" and href:
    print(f"Downloading CSS: {href}")
    css_str = get_resource(href).decode()

    new_style = link.makeelement("style")
    new_style.text = css_str
    link.getparent().replace(link, new_style)
  
  elif rel == "icon" and href:
    print(f"Downloading icon: {href}")
    icon_bytes = get_resource(href)
    icon_b64 = base64.b64encode(icon_bytes).decode()
    icon_type = link.get("type")
    link.set("href", f"data:{icon_type};base64,{icon_b64}")

for script in scripts:
  src = script.get("src")

  if src:
    print(f"Downloading JS: {src}")
    js_str = get_resource(src).decode()

    new_script = script.makeelement("script")
    new_script.text = js_str
    if "defer" in script.attrib:
      body.append(new_script)
      script.getparent().remove(script)
    else:
      script.getparent().replace(script, new_script)

out_path.write_bytes(b"<!DOCTYPE html>\n" + html.tostring(document))