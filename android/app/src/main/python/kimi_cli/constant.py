from __future__ import annotations

import importlib.metadata

try:
    VERSION = importlib.metadata.version("kimi-cli")
except importlib.metadata.PackageNotFoundError:
    VERSION = "0.0.0-local"

USER_AGENT = f"KimiCLI/{VERSION}"