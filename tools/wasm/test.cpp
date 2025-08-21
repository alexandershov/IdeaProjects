#include <vector>
#include <numeric>
#include <emscripten/emscripten.h>

// extern "C" to avoid C++ name mangling
extern "C" {
  // EMSCRIPTEN_KEEPALIVE so function is not compiled away
  EMSCRIPTEN_KEEPALIVE
  int sum_to_n(int n) {
    std::vector<int> v(n);
    std::iota(v.begin(), v.end(), 1);
    return std::accumulate(v.begin(), v.end(), 0);
  }
}
