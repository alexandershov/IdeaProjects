#include <chrono>
#include <iostream>
#include <random>

#define N 1000

void print_duration(const std::string &description, auto end, auto start) {
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    std::cout << description << " took " << duration.count() << "ms\n";
}

int main() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<int> dist(1, 100);
    // static so we don't exhaust stack size with 3 matrices
    static int x[N][N];
    static int y[N][N];
    static int yT[N][N];
    static int result[N][N];
    static int resultT[N][N];
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            x[i][j] = dist(gen);
            y[i][j] = dist(gen);
            result[i][j] = 0;
            resultT[i][j] = 0;
        }
    }

    // let's have naive matrix multiplication algorithm
    // it's slow because y[k][j] is not cache friendly: we jump by 1000 elements
    // x[i][k] is cache-friendly, we go 1 by 1
    auto start_naive = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            for (int k = 0; k < N; k++) {
                result[i][j] += x[i][k] * y[k][j];
            }
        }
    }
    auto end_naive = std::chrono::high_resolution_clock::now();
    // naive matmul took 326ms
    print_duration("naive matmul", end_naive, start_naive);

    // we can improve on naive implementation by first transposing y and then working with
    auto start_transposed = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            yT[i][j] = y[j][i];
        }
    }


    for (int i = 0; i < N; i++) {
          for (int j = 0; j < N; j++) {
              for (int k = 0; k < N; k++) {
                  resultT[i][j] += x[i][k] * yT[j][k];
              }
          }
    }
    auto end_transposed = std::chrono::high_resolution_clock::now();
    // transposed matmul took 70ms
    print_duration("transposed matmul", end_transposed, start_transposed);

    // transposed matmul is almost 5 times faster!
    // and it's doing more work: we include transposing in our calculations!
    // but cache is much faster than memory, that time spent on transposing doesn't matter!


    std::cout << "done!\n";
}