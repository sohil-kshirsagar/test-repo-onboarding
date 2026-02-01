import pytest
from hello import main
from io import StringIO
import sys


def test_main_prints_hello(capsys):
    """Test that main function prints expected output"""
    main()
    captured = capsys.readouterr()
    assert "Hello, World 2!" in captured.out
    assert "Hello, World 37!" in captured.out
