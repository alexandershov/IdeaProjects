# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pydantic",
# ]
# ///
import pydantic

def main():
    print(f"pydantic version == {pydantic.__version__}")

if __name__ == '__main__':
    main()