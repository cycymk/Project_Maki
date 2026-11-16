"""Tests for format_duration(seconds: int) -> str, per COLLAB.md T1.

Spec: return "mm:ss" for a non-negative number of seconds.
"""

import pytest

from utils import format_duration


@pytest.mark.parametrize(
    "seconds, expected",
    [
        # Zero boundary
        (0, "00:00"),
        # Seconds-only boundary (just under one minute)
        (1, "00:01"),
        (59, "00:59"),
        # Minute boundary
        (60, "01:00"),
        (61, "01:01"),
        # Spec example
        (65, "01:05"),
        # Just under one hour
        (3599, "59:59"),
        # Hour boundary: minutes keep counting past 59, no hours field
        (3600, "60:00"),
        (3601, "60:01"),
        # Multi-hour value
        (7322, "122:02"),
    ],
)
def test_format_duration_boundaries(seconds, expected):
    assert format_duration(seconds) == expected


def test_format_duration_returns_str():
    assert isinstance(format_duration(0), str)


def test_format_duration_pads_seconds_and_minutes_to_two_digits():
    assert format_duration(5) == "00:05"
    assert format_duration(600) == "10:00"
