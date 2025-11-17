"""Test if kimi-cli can be imported correctly"""

try:
    from kimi_cli.app import KimiCLI
    from kimi_cli.session import Session
    from kimi_cli.soul.kimisoul import KimiSoul
    from kimi_cli.utils.message import message_extract_text
    print("SUCCESS: All kimi-cli imports successful!")
    print(f"KimiCLI: {KimiCLI}")
    print(f"Session: {Session}")
    print(f"KimiSoul: {KimiSoul}")
    print(f"message_extract_text: {message_extract_text}")
except Exception as e:
    print(f"ERROR: Failed to import kimi-cli: {e}")
    import traceback
    traceback.print_exc()
