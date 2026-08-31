import subprocess


def main():
    i = 0
    while True:
        subprocess.run(["rm", "-rf", "./rr_trace"], check=True)
        print(f"attempt #{i}")
        proc = subprocess.run(["rr", "record", "-o", "rr_trace", "debug"])
        if proc.returncode != 0:
            print("reproed! run rr replay ../rr_trace")
            return
        i += 1


if __name__ == "__main__":
    main()
