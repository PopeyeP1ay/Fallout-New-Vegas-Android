#!/usr/bin/env python3
"""Check tracked repository paths and authored text for publication hazards.

This intentionally does not claim to compile or validate the private game port.
"""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
BLOCKED_SUFFIXES = {
    ".apk", ".aab", ".obb", ".bsa", ".ba2", ".esm", ".esp", ".esl",
    ".exe", ".dll", ".so", ".nif", ".dds", ".mp3", ".wav", ".ogg",
    ".zip", ".7z", ".rar", ".jks", ".keystore", ".p12", ".pem",
    ".fos", ".sav", ".tombstone",
}
BLOCKED_NAMES = {"falloutnv.exe", "local.properties", ".env"}
BLOCKED_DIRS = {
    "data", "gamefiles", "game", "backups", "build", "out",
    "artifacts", ".gradle", ".cxx", "private", "saves",
}
TEXT_SUFFIXES = {".md", ".ps1", ".py", ".yml", ".yaml", ".txt", ".sh"}
# Detect an embedded Windows drive path without listing anyone's actual path.
ABSOLUTE_DRIVE_PATH = re.compile(r"\b[A-Za-z]:[\\/]")
errors = []

try:
    result = subprocess.run(
        ["git", "ls-files", "-z"], cwd=ROOT, check=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    tracked = [Path(p.decode("utf-8", errors="replace")) for p in result.stdout.split(b"\0") if p]
except (subprocess.CalledProcessError, FileNotFoundError) as exc:
    print("Could not obtain tracked files:", exc, file=sys.stderr)
    sys.exit(2)

for rel in tracked:
    path = ROOT / rel
    parts = [p.lower() for p in rel.parts]
    if rel.suffix.lower() in BLOCKED_SUFFIXES or rel.name.lower() in BLOCKED_NAMES:
        errors.append(f"Blocked file type/name: {rel}")
    if any(p in BLOCKED_DIRS for p in parts[:-1]):
        errors.append(f"Blocked repository directory: {rel}")
    if path.is_file() and rel.suffix.lower() in TEXT_SUFFIXES:
        try:
            body = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            errors.append(f"Text file is not UTF-8: {rel}")
            continue
        if ABSOLUTE_DRIVE_PATH.search(body):
            errors.append(f"Machine-specific absolute path found: {rel}")

must_exist = [
    "README.md", "WORKFLOW.md", "DEVELOPMENT_STATUS.md", "MODS.md",
    "RELEASE_CHECKLIST.md", "LICENSES_AND_DISTRIBUTION.md",
    "tools/Local-Workflow.ps1", ".github/workflows/verify-repository.yml",
]
for item in must_exist:
    if not (ROOT / item).is_file():
        errors.append(f"Required workflow file missing: {item}")

if errors:
    print("Repository verification FAILED:")
    for error in errors:
        print(" -", error)
    sys.exit(1)
print(f"Repository verification passed for {len(tracked)} tracked files.")
print("Note: native APK build and device tests are not performed in this workflow.")
