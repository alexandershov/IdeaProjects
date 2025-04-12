import argparse
import subprocess


def main():
    args = parse_args()
    max_threads = args.max_threads
    engine_path = args.engine_path

    print(f"Testing UCI engine at {engine_path} with up to {max_threads} threads.")

    nps_stats = []
    for threads in range(1, max_threads + 1):
        nps = test_uci_engine(engine_path, threads)
        nps_stats.append((threads, nps))
        print(f"Threads: {threads}, NPS: {nps}")

    print("NPS stats by threads:")
    for threads, nps in nps_stats:
        print(f"{threads} threads -> NPS: {nps}")


def test_uci_engine(engine_path: str, threads: int) -> float:
    """
    Test the UCI engine with the specified number of threads and return the NPS (nodes per second) value.

    :param engine_path: Path to the UCI engine executable.
    :param threads: Number of threads to set for the UCI engine.
    :return: NPS (nodes per second) value as a float.
    """
    try:
        # Run the UCI engine process
        process = subprocess.Popen(
            engine_path,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )

        # Interact with the UCI engine
        # process.stdin.write(f"setoption name Threads value {threads}\n")
        process.stdin.write(f"bench 256 {threads} 15\n")
        process.stdin.flush()

        nps = None
        while True:
            line = process.stdout.readline()
            if "Nodes/second" in line:
                nps = float(line.split(":")[1].strip())
                break
            if not line:
                break

        # Ensure the process is closed
        process.stdin.write("quit\n")
        process.stdin.flush()
        process.terminate()

        if nps is None:
            raise ValueError("NPS stat not found in UCI engine output.")

        return nps
    except Exception as e:
        print(f"Error testing UCI engine with {threads} threads: {e}")
        return 0.0


def parse_args():
    parser = argparse.ArgumentParser(description="UCI Engine Benchmarking Tool")
    parser.add_argument(
        "--max-threads",
        type=int,
        required=True,
        help="Maximum number of threads to test with the UCI engine."
    )
    parser.add_argument(
        "--engine-path",
        type=str,
        required=True,
        help="Path to the UCI engine executable."
    )
    return parser.parse_args()


if __name__ == '__main__':
    main()
