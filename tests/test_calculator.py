import pytest
from utils.calculator import add

def test_add():
    assert add(1, 2) == 3
