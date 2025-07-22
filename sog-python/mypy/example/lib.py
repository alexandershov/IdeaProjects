def add(x: int, y: int) -> int:
    return x + y


def _fn(x: int, y: int) -> int:
    return x + y

globals()["fn"] = _fn