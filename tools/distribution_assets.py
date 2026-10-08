"""Fail-closed checks for distribution artwork and PE resources.

The hashes identify the existing project-created fallback artwork. They are not
hashes of game assets. Adding artwork requires an explicit provenance review.
Local game-derived markers must never be added to this allowlist.
"""
from __future__ import annotations
import hashlib
from pathlib import PurePosixPath
import struct

ARTWORK = {
    "core/assets/Tablet_Interaktion.png": "1f0544a2bac80ff0254fc0e8ebdd729519778b20333c0da5f67e6e82fc3f0099",
    "core/assets/Tablet_Interaktion_zielsymbol.png": "6f7f6e4d845a0622eb2dd8036ff546a8268a012ccbfa087d43a9765683739f70",
    "core/assets/Stun_Fist.png": "6c4f4007af53eab4bb95e3f304aa984389bd26f427dc1d44a9c3b44afb73f431",
    "docs/touch-hand.png": "3e80fb099a2c671b95608d7663ed5ddfbdfb73da904c2194839aef048f26abef",
    "docs/crosshair.png": "e04ecdc0fe5aa1268abf9c659b4f7bd6fdd2bc2705441bcccb42c2c29d287ab0",
    "docs/stun-fist.png": "6c4f4007af53eab4bb95e3f304aa984389bd26f427dc1d44a9c3b44afb73f431",
}
RESOURCE_ARTWORK = {101: ARTWORK["core/assets/Tablet_Interaktion.png"],
                    102: ARTWORK["core/assets/Tablet_Interaktion_zielsymbol.png"],
                    103: ARTWORK["core/assets/Stun_Fist.png"]}
# The build's application manifest, not an opaque arbitrary resource container.
MANIFEST_HASH = "4bb79dcea0a901f7d9eac5aa05728ae92acb42e0cb22e5dd14134f4421a3d8df"
PNG = b"\x89PNG\r\n\x1a\n"
LOCAL_MARKERS = {"stun-hammer.png", "aim-radish.png", "touch-switch.png", "touch-coin.png"}
TEXT_SUFFIXES = {".md", ".txt", ".cs", ".h", ".cpp", ".asm", ".def", ".rc", ".py", ".ps1", ".cmd", ".json"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def audit_pe(data: bytes) -> None:
    """Allow only the three reviewed fallback PNGs and the build manifest."""
    try:
        if data[:2] != b"MZ":
            raise ValueError("DLL is not a PE image")
        pe = struct.unpack_from("<I", data, 0x3c)[0]
        if data[pe:pe+4] != b"PE\0\0":
            raise ValueError("Invalid PE signature")
        opt = pe + 24
        if struct.unpack_from("<H", data, opt)[0] != 0x20b:
            raise ValueError("Expected x64 PE image")
        count = struct.unpack_from("<H", data, pe+6)[0]
        opt_size = struct.unpack_from("<H", data, pe+20)[0]
        sections = [struct.unpack_from("<8sIIII", data, opt+opt_size+40*i) for i in range(count)]
        rva, size = struct.unpack_from("<II", data, opt+112+16)

        def offset(r, length):
            for _, _, va, raw_size, raw in sections:
                if va <= r and r + length <= va + raw_size:
                    pos = raw + r - va
                    if pos + length <= len(data):
                        return pos
            raise ValueError("PE resource outside file-backed section")

        base = offset(rva, size)
        seen = set()

        def resource(rel, length):
            if rel < 0 or rel + length > size:
                raise ValueError("PE resource directory outside resource section")
            return base + rel

        def walk(rel, path=()):
            if len(path) > 2:
                raise ValueError("Unexpected PE resource nesting")
            named, ids = struct.unpack_from("<HH", data, resource(rel, 16)+12)
            if named:
                raise ValueError("Unreviewed named PE resource")
            for i in range(ids):
                key, value = struct.unpack_from("<II", data, resource(rel+16+8*i, 8))
                route = path + (key,)
                if value & 0x80000000:
                    walk(value & 0x7fffffff, route)
                else:
                    if len(route) != 3 or route in seen:
                        raise ValueError("Unexpected or duplicate PE resource")
                    seen.add(route)
                    start, length, _, _ = struct.unpack_from("<IIII", data, resource(value, 16))
                    pos = offset(start, length)
                    payload = data[pos:pos+length]
                    expected = (RESOURCE_ARTWORK.get(route[1]) if route[0] == 10 else
                                MANIFEST_HASH if route[:2] == (24, 2) else None)
                    if expected is None or sha(payload) != expected:
                        raise ValueError(f"Unreviewed DLL resource: {route}")
        walk(0)
        if {p[1] for p in seen if p[0] == 10} != set(RESOURCE_ARTWORK):
            raise ValueError("Missing reviewed fallback resource")
    except (struct.error, IndexError) as exc:
        raise ValueError("Malformed DLL resource data") from exc


def audit_assets(files: dict[str, bytes]) -> None:
    for name, data in files.items():
        path = PurePosixPath(name.replace("\\", "/"))
        if path.is_absolute() or ".." in path.parts:
            raise ValueError(f"Invalid package path: {name}")
        if "marker-icons" in str(path).lower().split("/") or path.name.lower() in LOCAL_MARKERS:
            raise ValueError(f"Local game-derived marker in distribution: {name}")
        if str(path) in ARTWORK:
            if sha(data) != ARTWORK[str(path)]:
                raise ValueError(f"Artwork changed without provenance review: {name}")
        elif str(path) == "layer/cemuvr_layer.dll":
            audit_pe(data)
        elif path.suffix.lower() not in TEXT_SUFFIXES and str(path) not in {"LICENSE", "VERSION", ".gitignore", ".gitattributes"}:
            raise ValueError(f"Unreviewed binary/asset file: {name}")
        elif b"\0" in data:
            raise ValueError(f"Binary data disguised as text: {name}")
        # Also catch PNGs renamed as text, appended to a DLL, or embedded outside
        # the reviewed resource table. No decoder dependency is needed.
        cursor = 0
        while True:
            start = data.find(PNG, cursor)
            if start < 0:
                break
            end = start + len(PNG)
            while True:
                if end + 12 > len(data):
                    raise ValueError(f"Truncated embedded PNG: {name}")
                length = struct.unpack_from(">I", data, end)[0]
                kind = data[end+4:end+8]
                end += 12 + length
                if end > len(data):
                    raise ValueError(f"Truncated PNG chunk: {name}")
                if kind == b"IEND":
                    break
            if sha(data[start:end]) not in set(ARTWORK.values()):
                raise ValueError(f"Unreviewed PNG content: {name}")
            cursor = end
