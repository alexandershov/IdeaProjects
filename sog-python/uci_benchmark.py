"""
Results:

Hetzner
AMD 2 dedicated CPU (0.03USD/hour)
1M nps costs 0.026 USD/hour
NPS stats by threads:
1 threads -> NPS: 1201141.0
2 threads -> NPS: 1633865.0
3 threads -> NPS: 1735324.0
4 threads -> NPS: 1871773.0

AMD 16 vCPU (0.12USD/hour)
1M nps costs 0.007 USD/hour
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

Amper 16 CPU (0.05USD/hour)
1M nps costs 0.006 USD/hour
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

Intel 4 CPU (0.015USD/hour)
1M nps costs 0.0057 USD/hour
Threads: 1, NPS: 402515.0
Threads: 2, NPS: 1004552.0
Threads: 3, NPS: 1511071.0
Threads: 4, NPS: 2131307.0
Threads: 5, NPS: 2190455.0
Threads: 6, NPS: 2085084.0

AWS:
c7a.4xlarge (0.94USD/hour)
1M NPS costs 0.05USD/hour
Threads: 1, NPS: 1219575.0
Threads: 2, NPS: 2565295.0
Threads: 3, NPS: 3974578.0
Threads: 4, NPS: 5405843.0
Threads: 5, NPS: 7269234.0
Threads: 6, NPS: 8391377.0
Threads: 7, NPS: 9908934.0
Threads: 8, NPS: 11490308.0
Threads: 9, NPS: 13094459.0
Threads: 10, NPS: 14664632.0
Threads: 11, NPS: 16445700.0
Threads: 12, NPS: 17449683.0
Threads: 13, NPS: 19375387.0
Threads: 14, NPS: 20521869.0
Threads: 15, NPS: 22438775.0
Threads: 16, NPS: 23335038.0
Threads: 17, NPS: 25262827.0
Threads: 18, NPS: 24071088.0
Threads: 19, NPS: 22810939.0
Threads: 20, NPS: 22474498.0

c7i.4xlarge (0.81USD/hour)
1M NPS costs 0.05USD/hour
Threads: 1, NPS: 1045350.0
Threads: 2, NPS: 2270916.0
Threads: 3, NPS: 3429352.0
Threads: 4, NPS: 4743182.0
Threads: 5, NPS: 6117882.0
Threads: 6, NPS: 7588108.0
Threads: 7, NPS: 8726569.0
Threads: 8, NPS: 9741727.0
Threads: 9, NPS: 9695398.0
Threads: 10, NPS: 11004371.0
Threads: 11, NPS: 10934997.0
Threads: 12, NPS: 11283999.0
Threads: 13, NPS: 11929946.0
Threads: 14, NPS: 12208736.0
Threads: 15, NPS: 13423938.0
Threads: 16, NPS: 13465151.0
Threads: 17, NPS: 13133248.0
Threads: 18, NPS: 14074882.0
Threads: 19, NPS: 13042634.0
Threads: 20, NPS: 13525453.0

c8g.4xlarge (0.73USD/hour)
1M nps costs 0.05USD/hour
Threads: 1, NPS: 720455.0
Threads: 2, NPS: 1658981.0
Threads: 3, NPS: 2588320.0
Threads: 4, NPS: 3631508.0
Threads: 5, NPS: 4582133.0
Threads: 6, NPS: 5359869.0
Threads: 7, NPS: 6342895.0
Threads: 8, NPS: 7017485.0
Threads: 9, NPS: 7942739.0
Threads: 10, NPS: 9325440.0
Threads: 11, NPS: 10144254.0
Threads: 12, NPS: 11080491.0
Threads: 13, NPS: 12573167.0
Threads: 14, NPS: 13343804.0
Threads: 15, NPS: 13753629.0
Threads: 16, NPS: 15720279.0

c7g.4xlarge (0.66USD/hour)
1M nps costs 0.05USD/hour
Threads: 1, NPS: 673732.0
Threads: 2, NPS: 1454824.0
Threads: 3, NPS: 2184081.0
Threads: 4, NPS: 3007384.0
Threads: 5, NPS: 3811681.0
Threads: 6, NPS: 4819294.0
Threads: 7, NPS: 5347882.0
Threads: 8, NPS: 6439284.0
Threads: 9, NPS: 7182264.0
Threads: 10, NPS: 7717660.0
Threads: 11, NPS: 9103973.0
Threads: 12, NPS: 9921036.0
Threads: 13, NPS: 11111041.0
Threads: 14, NPS: 11213817.0
Threads: 15, NPS: 12573912.0
Threads: 16, NPS: 12998798.0
Threads: 17, NPS: 12642854.0
Threads: 18, NPS: 12542687.0
Threads: 19, NPS: 12552263.0
Threads: 20, NPS: 14641893.0
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
