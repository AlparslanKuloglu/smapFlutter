#!/usr/bin/env python3
"""Turns a Claude Design HTML export into the layout of docs/design/panolar.

    python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-14.html
    python3 tool/design/html_to_boards.py docs/design/kaynak/SMAP-14.html --only 14.8

A Claude Design export is one HTML file that packs every board of a page as a
nested bundle (fonts and the canvas runtime inside, unpacked by a script when
the file opens). For each board this script:

1. unpacks the nested bundle into one self-contained HTML file,
2. opens it in headless Google Chrome and lets the runtime draw it,
3. writes the drawn board:
   - docs/design/panolar/png/SMAP-NN_<NN-board>.png   (the image, 1x),
   - docs/design/panolar/SMAP-NN/<NN-board>/board.html (the drawn DOM with its
     CSS, fonts left out, for exact sizes and colors),
   - docs/design/panolar/SMAP-NN/<NN-board>/text.txt   (the board's text).

Needs Python 3 (standard library only) and Google Chrome. The boards run
their own JavaScript inside a throwaway Chrome profile; only run this on
exports you trust (your own Claude Design files).
"""
from __future__ import annotations

import argparse
import base64
import gzip
import html
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import zlib
from pathlib import Path

CHROME = os.environ.get(
    "CHROME", "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
)
RENDER_MS = 8000
UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
SIZE_PROBE = """
<script>
window.addEventListener('load', function () {
  setTimeout(function () {
    var e = document.documentElement, b = document.body;
    var w = Math.max(e.scrollWidth, b ? b.scrollWidth : 0);
    var h = Math.max(e.scrollHeight, b ? b.scrollHeight : 0);
    document.title = '__SIZE__' + w + 'x' + h;
  }, 2500);
});
</script>
"""


def _script(page: str, kind: str) -> str | None:
    match = re.search(
        r'<script type="' + re.escape(kind) + r'"[^>]*>(.*?)</script>', page, re.S
    )
    return match.group(1) if match else None


def _bytes(resource: dict) -> bytes:
    raw = base64.b64decode(resource["data"])
    if str(resource.get("compressed", "")).lower() == "true":
        try:
            raw = gzip.decompress(raw)
        except OSError:
            raw = zlib.decompress(raw)
    return raw


def _bundle(page: str) -> tuple[dict, str | None, list | None]:
    manifest = json.loads(_script(page, "__bundler/manifest") or "{}")
    template = _script(page, "__bundler/template")
    order = _script(page, "__bundler/page_order")
    return (
        manifest,
        json.loads(template) if template else None,
        json.loads(order) if order else None,
    )


def _inline(template: str, manifest: dict) -> str:
    """The template with every resource uuid replaced by a data: URI."""

    def data_uri(match: re.Match) -> str:
        resource = manifest.get(match.group(0))
        if resource is None:
            return match.group(0)
        body = base64.b64encode(_bytes(resource)).decode()
        return f"data:{resource.get('mime', 'application/octet-stream')};base64,{body}"

    return UUID.sub(data_uri, template)


def _boards(path: Path) -> list[str]:
    """Each board of the export as a self-contained HTML page."""
    manifest, template, order = _bundle(path.read_text(encoding="utf-8"))
    pages = []
    for key in order or list(manifest):
        page = _bytes(manifest[key]).decode("utf-8")
        inner_manifest, inner_template, _ = _bundle(page)
        if inner_template is None:  # already a plain page
            pages.append(page)
            continue
        pages.append(_inline(inner_template, inner_manifest))
    if not pages and template:
        pages.append(_inline(template, manifest))
    return pages


def _chrome(args: list[str], profile: str, done, timeout: float = 90) -> None:
    """Runs headless Chrome until [done]() is true, then stops it.

    Headless Chrome writes its result (the DOM, the screenshot) but often does
    not exit afterwards while the page keeps timers running, so the result is
    polled for and the process is ended once it is there.
    """
    cmd = [
        CHROME,
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--no-first-run",
        "--no-default-browser-check",
        f"--user-data-dir={profile}",
        f"--virtual-time-budget={RENDER_MS}",
        *args,
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    waited = 0.0
    try:
        while waited < timeout:
            if done():
                time.sleep(0.5)
                return
            if proc.poll() is not None:
                return
            time.sleep(0.5)
            waited += 0.5
        raise TimeoutError(f"Chrome gave no result in {timeout:.0f} s: {' '.join(args[-1:])}")
    finally:
        if proc.poll() is None:
            proc.kill()
            proc.wait()


def _dump_dom(url: str, profile: str, work: Path) -> str:
    out = work / "dom.html"
    out.unlink(missing_ok=True)
    with out.open("w", encoding="utf-8") as handle:
        cmd_done = lambda: out.exists() and "</html>" in out.read_text(encoding="utf-8", errors="ignore")
        proc_args = ["--dump-dom", url]
        # stdout goes to the file: start Chrome with it redirected.
        cmd = [
            CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
            "--no-default-browser-check", f"--user-data-dir={profile}",
            f"--virtual-time-budget={RENDER_MS}", *proc_args,
        ]
        proc = subprocess.Popen(cmd, stdout=handle, stderr=subprocess.DEVNULL)
        waited = 0.0
        try:
            while waited < 90:
                handle.flush()
                if cmd_done():
                    time.sleep(0.5)
                    break
                if proc.poll() is not None:
                    break
                time.sleep(0.5)
                waited += 0.5
            else:
                raise TimeoutError(f"Chrome gave no DOM in 90 s: {url}")
        finally:
            if proc.poll() is None:
                proc.kill()
                proc.wait()
    return out.read_text(encoding="utf-8", errors="ignore")


def _screenshot(url: str, png: Path, width: int, height: int, profile: str) -> None:
    png.unlink(missing_ok=True)
    sizes: list[int] = []

    def done() -> bool:
        if not png.exists():
            return False
        sizes.append(png.stat().st_size)
        return len(sizes) >= 2 and sizes[-1] == sizes[-2] and sizes[-1] > 0

    _chrome([f"--screenshot={png}", f"--window-size={width},{height}", url], profile, done)


BLOCK = re.compile(
    r"</?(?:p|div|h[1-6]|li|ul|ol|tr|table|section|article|header|footer|br|figcaption)\b[^>]*>",
    re.I,
)


def _text(dom: str) -> str:
    body = re.sub(r"<(script|style)\b.*?</\1>", "", dom, flags=re.S | re.I)
    body = BLOCK.sub("\n", body)
    body = re.sub(r"<[^>]+>", " ", body)
    lines = [re.sub(r"[ \t ]+", " ", html.unescape(line)).strip() for line in body.splitlines()]
    out, blank = [], False
    for line in lines:
        if not line:
            blank = True
            continue
        if blank and out:
            out.append("")
        out.append(line)
        blank = False
    return "\n".join(out) + "\n"


CODE = re.compile(r"\s*(\d+)\.(\d+)((?:\s+ek)?)\b")


def _slug(index: int, title: str, heading: str | None, text: str) -> str:
    """"NN-X-Y-<words>": board index, board code and the heading's words.

    The code comes from the title ("14.8 Koç …") or, for delivery boards whose
    title has none, from the eyebrow line at the top ("11.13 ek · Geliştirici
    Teslimi").
    """
    code = CODE.match(title)
    name = heading or title
    if code:
        name = re.sub(r"^\s*\d+\.\d+\s*·?\s*", "", name)
    else:
        code = next(filter(None, (CODE.match(line) for line in text.splitlines()[:6])), None)
    words = re.sub(r"[^0-9A-Za-zÇĞİÖŞÜçğıöşüÂâÎîÛû]+", "-", name).strip("-")
    prefix = f"{code.group(1)}-{code.group(2)}-{'ek-' if code.group(3) else ''}" if code else ""
    return f"{index:02d}-{prefix}{words}"[:90].rstrip("-")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("export", type=Path, help="docs/design/kaynak/SMAP-NN.html")
    parser.add_argument("--only", help="render only the board whose code starts with this (e.g. 14.8)")
    parser.add_argument("--out", type=Path, help="output root (default docs/design/panolar)")
    options = parser.parse_args()

    if not Path(CHROME).exists():
        print(f"Google Chrome not found at {CHROME} (set CHROME=...)", file=sys.stderr)
        return 1
    page_name = re.sub(r"\s+", "", options.export.stem)  # "SMAP-14"
    root = options.out or Path(__file__).resolve().parents[2] / "docs" / "design" / "panolar"
    (root / "png").mkdir(parents=True, exist_ok=True)

    work = Path(tempfile.mkdtemp(prefix="smap-boards-"))
    profile = str(work / "profile")
    try:
        for index, board in enumerate(_boards(options.export)):
            title_match = re.search(r"<title>(.*?)</title>", board, re.S)
            title = html.unescape(title_match.group(1)).strip() if title_match else f"board {index}"
            if options.only and not re.match(re.escape(options.only) + r"(?!\d)", title):
                continue
            source = work / f"board{index:02d}.html"
            source.write_text(board.replace("</body>", SIZE_PROBE + "</body>", 1), encoding="utf-8")
            dom = _dump_dom(source.as_uri(), profile, work)
            size = re.search(r"__SIZE__(\d+)x(\d+)", dom)
            width, height = (int(size.group(1)), int(size.group(2))) if size else (1440, 1600)
            heading = re.search(r"<h1\b[^>]*>(.*?)</h1>", dom, re.S)
            heading_text = (
                re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", heading.group(1)))).strip()
                if heading
                else None
            )
            slug = _slug(index, title, heading_text, _text(dom))
            folder = root / page_name / slug
            folder.mkdir(parents=True, exist_ok=True)
            png = root / "png" / f"{page_name}_{slug}.png"
            _screenshot(source.as_uri(), png, width, height, profile)
            clean = re.sub(r"<script\b.*?</script>", "", dom, flags=re.S | re.I)
            clean = re.sub(r"url\(\"?data:font/[^)]*\)", 'url("")', clean)
            clean = clean.replace(f"__SIZE__{width}x{height}", title)
            (folder / "board.html").write_text(clean, encoding="utf-8")
            (folder / "text.txt").write_text(_text(clean), encoding="utf-8")
            print(f"{page_name}/{slug}  {width}x{height}")
    finally:
        shutil.rmtree(work, ignore_errors=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
