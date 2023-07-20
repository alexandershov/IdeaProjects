from dataclasses import dataclass

import hypothesis.strategies as st
from hypothesis import example
from hypothesis import given
from hypothesis.stateful import RuleBasedStateMachine
from hypothesis.stateful import invariant
from hypothesis.stateful import precondition
from hypothesis.stateful import rule


# hypothesis is a property-based testing library
# you provide some properties about your function
# in contrast to usual tests where you provide explicit examples
# e.g. deserialize(serialize(X)) == X is a property, exact value of X doesn't matter
# hypothesis can generate random examples that check this property
# the testing done by hypothesis will be more rigorous than example-based
# testing


def broken_add(a, b):
    # bug when a > 256
    if a > 256:
        return a + b - 1
    return a + b


# st.integers() generates random integers
# this test will fail
# what's cool about hypotheses is that it will fail with a=257
# because hypothesis tries to find the minimal failing example
# not just the first random one (this is called shrinking)
@given(a=st.integers(), b=st.integers())
def test_broken_add(a, b):
    assert broken_add(a, b) == a + b


def broken_sum(seq):
    if len(seq) == 3:  # bug when len(seq) == 3
        return sum(seq[:2])
    return sum(seq)


# hypothesis can generate lists of X and other types
# this also will find the minimal failing example
@given(st.lists(st.integers()))
def test_broken_sum(seq):
    assert broken_sum(seq) == sum(seq)


@dataclass(frozen=True)
class Person:
    name: str
    age: int

    def serialize(self):
        return {'name': self.name.strip(), 'age': self.age}

    @staticmethod
    def deserialize(data):
        return Person(data['name'], data['age'])


# hypothesis works with data classes and respects type hints
@given(st.builds(Person))
# while using hypothesis you can still test the usual way with @example
@example(Person(name='sasa', age=38))
def test_person_serde(person: Person):
    assert Person.deserialize(person.serialize()) == person


class BrokenList:
    def __init__(self):
        self._items = []
        self._was_popped = False

    def __len__(self):
        return len(self._items)

    def append(self, value):
        # bug when len == 3 and pop() was called
        if len(self._items) == 3 and self._was_popped:
            return
        self._items.append(value)

    def pop(self):
        self._was_popped = True
        return self._items.pop()


# hypothesis can write test scenarios
# here we have a list that can't grow over 3 elements if pop was called earlier
# hypothesis will generate a test scenario with 4 appends and 1 pop
# this is called stateful testing
# more info is here https://hypothesis.readthedocs.io/en/latest/stateful.html
class BrokenListMachine(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self._broken_list = BrokenList()
        self._count = 0

    # we use named arguments, to skip `self`
    @rule(value=st.integers())
    def append(self, value):
        self._broken_list.append(value)
        self._count += 1
        assert len(self._broken_list) == self._count

    @rule()
    # pop will be called only on non-empty lists
    @precondition(lambda self: self._count > 0)
    def pop(self):
        self._broken_list.pop()
        self._count -= 1
        assert len(self._broken_list) == self._count

    # with @invariant, we can comment out asserts in `pop` and `append`
    @invariant()
    def len_is_correct(self):
        assert len(self._broken_list) == self._count


# extract test case, so pytest can execute TestBrokenList
TestBrokenList = BrokenListMachine.TestCase
