# see comment in `main` function for details

import math
import random
import statistics

import typer


def oracle(amplitudes, i):
    # oracle flips
    amplitudes[i] *= -1


def inversion(x, axis):
    return 2 * axis - x


def inversion_about_the_mean(amplitudes):
    mean = statistics.mean(amplitudes)
    for i, a in enumerate(amplitudes):
        amplitudes[i] = inversion(a, mean)


def total_prob(amplitudes):
    return sum(a ** 2 for a in amplitudes)


def main(qubits: int):
    num_states = 2 ** qubits
    answer = random.randint(0, num_states - 1)
    print(f'{answer=}')
    # given a quantum system with `qubits`
    # we have 2 ** qubits of states in superposition
    # each state has the same amplitude, no complex numbers involved
    amplitudes = [1 / math.sqrt(num_states)] * num_states
    for _ in range(10):
        # oracle takes a quantum state and flips the sign of amplitude
        # of the correct answer. Suppose that we can have such an oracle.
        oracle(amplitudes, answer)
        # we take a mean of all amplitudes and invert everything around it
        inversion_about_the_mean(amplitudes)
        # the result of it will be that amplitude of the answer will increase
        # and the amplitudes of other states will decrease
        print(f'{amplitudes=}')
        print(f'total_prob = {total_prob(amplitudes)}')
    # after repeating oracle+inversion enough times (sqrt(2 ** qubits) to be exact)
    # we'll have a large amplitude for the answer
    # then we measure quantum state
    # with the high probability we'll get the correct answer


if __name__ == '__main__':
    typer.run(main)
