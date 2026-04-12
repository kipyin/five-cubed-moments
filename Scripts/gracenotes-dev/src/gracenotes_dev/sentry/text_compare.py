"""Small string helpers for comparing agent output to file content."""


def text_effectively_same(a: str, b: str) -> bool:
    """Ignore CRLF vs LF and trailing newline differences when comparing agent output."""
    return a.replace("\r\n", "\n").rstrip() == b.replace("\r\n", "\n").rstrip()
