"""
Results:

AMD 2 dedicated CPU
NPS stats by threads:
1 threads -> NPS: 1201141.0
2 threads -> NPS: 1633865.0
3 threads -> NPS: 1735324.0
4 threads -> NPS: 1871773.0

AMD 16 vCPU
1 threads -> NPS: 971579.0
2 threads -> NPS: 2033657.0
3 threads -> NPS: 3205828.0
4 threads -> NPS: 4343024.0
5 threads -> NPS: 5549367.0
6 threads -> NPS: 6713037.0
7 threads -> NPS: 7844927.0
8 threads -> NPS: 9271082.0
9 threads -> NPS: 10400672.0
10 threads -> NPS: 11755303.0
11 threads -> NPS: 13182423.0
12 threads -> NPS: 13810703.0
13 threads -> NPS: 19312880.0
14 threads -> NPS: 16853868.0
15 threads -> NPS: 18112470.0
16 threads -> NPS: 19441329.0
17 threads -> NPS: 19086644.0
18 threads -> NPS: 21894412.0
19 threads -> NPS: 18269879.0
20 threads -> NPS: 19949198.0

Amper 16 CPU
Threads: 1, NPS: 440270.0
Threads: 2, NPS: 893484.0
Threads: 3, NPS: 1401836.0
Threads: 4, NPS: 1946871.0
Threads: 5, NPS: 2446928.0
Threads: 6, NPS: 2908824.0
Threads: 7, NPS: 3671277.0
Threads: 8, NPS: 3886874.0
Threads: 9, NPS: 4594095.0
Threads: 10, NPS: 5499162.0
Threads: 11, NPS: 5352778.0
Threads: 12, NPS: 6308980.0
Threads: 13, NPS: 6514097.0
Threads: 14, NPS: 7292153.0
Threads: 15, NPS: 7916275.0
Threads: 16, NPS: 8199009.0
Threads: 17, NPS: 9625661.0
Threads: 18, NPS: 8343695.0
Threads: 19, NPS: 7817520.0
Threads: 20, NPS: 8193022.0
"""

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
