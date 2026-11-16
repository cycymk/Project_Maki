def format_duration(seconds: int) -> str:
    """Format a duration as zero-padded minutes and seconds."""
    minutes, remaining_seconds = divmod(seconds, 60)
    return f"{minutes:02d}:{remaining_seconds:02d}"
