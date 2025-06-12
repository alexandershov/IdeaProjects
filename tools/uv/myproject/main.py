import starlette
import fastapi

def main():
    print("Hello from myproject!")
    print(f"starlette version = {starlette.__version__}")


if __name__ == "__main__":
    main()
