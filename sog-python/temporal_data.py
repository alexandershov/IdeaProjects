from dataclasses import dataclass


@dataclass(frozen=True)
class Params:
    url: str
    message: str
