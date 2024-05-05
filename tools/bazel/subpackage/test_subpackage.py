import unittest

import adder


class TestCase(unittest.TestCase):
    def test_add(self):
        self.assertEqual(adder.add(1, 2), 3)
