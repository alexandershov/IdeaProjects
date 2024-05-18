import unittest
import urllib.error
import urllib.request

import adder


class TestCase(unittest.TestCase):
    def test_add(self):
        self.assertEqual(adder.add(1, 2), 3)

    def test_block_network_tag(self):
        with self.assertRaises(urllib.error.URLError):
            with urllib.request.urlopen("http://google.com") as response:
                print(response.read())


if __name__ == '__main__':
    unittest.main()
