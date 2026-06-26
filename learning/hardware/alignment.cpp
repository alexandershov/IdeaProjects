#include <iostream>

typedef struct padding_t {
    char c1;
    int i;
} padding_t;

typedef struct no_padding_t {
    int i;
    char c1;
} no_padding_t;

int main() {
    padding_t p;
    no_padding_t np;
    /*
    difference between p.i and p.c1 is 4!
    but why?
    the answer is padding.

    Let's say CPU wants to get a word (word is 64 bits on 64-bit machine) at address A
    Word should be located at address A such that A == 64 * k.
    In this case CPU would need to get 1 word from memory.
    If A != 64 * k, then to get our word we would need to get 2 words from memory: our word is a the boundary
    of 2 words.

    For data types that are less than a word the rule for alignment is:
    let's say data type size n == 2^z (z = 0, 1, 2, ...).
    Then this data type should be located at A == k * n
    Then CPU will be able to get our data type by reading 1 word.
    Proof: if our data is word, then it's trivial.
    If our data is less than word, then our address is k * 2^z, our size is 2^z
    this means our data is at the interval [k * 2^z; k * 2^z + 2^z) == [k * 2^z; (k + 1)* 2^z)
    this interval is 2 consecutive powers of 2. There can be no word boundary between these numbers,
    because word boundary is power of two

    Going back to our example p.i needs to be aligned, so compiler inserts 3 bytes after p.c1
    That's why pointer difference is 4
     */
    std::cout << "padding in padding_t = " << (char*)&(p.i) - (char*)&p.c1 << "\n";
    // difference between p.c1 and p.i is also 4, but there's no padding involved
    // np.c1 is placed at power ot 2 already
    std::cout << "padding in no_padding_t = " << (char*)&(np.c1) - (char*)&np.i << "\n";
    std::cout << "done!\n";
}