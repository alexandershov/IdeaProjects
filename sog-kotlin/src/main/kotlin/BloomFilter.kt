import java.security.MessageDigest
import java.util.BitSet
import kotlin.math.pow

interface MD5Hashable {
    fun md5Hash(): String
}

class MD5HashableString(private val s: String) : MD5Hashable {

    override fun md5Hash(): String {
        val md = MessageDigest.getInstance("MD5")
        return md.digest(s.toByteArray()).joinToString("") { "%02x".format(it) }
    }
}

class BloomFilter<T : MD5Hashable>(size: Int, numHashes: Int) {
    /*
    BloomFilter is a probabilistic data structure that allows us to check
    if the element is in the set. Protocol of work is "Hell no or maybe".
    If `contains` returns false, then the element is definitely not in the set.
    If `contains` returns true, then the element is maybe in the set
    with some probability.

    Main idea is this: we have a large bitset.
    When we add an element to a set, we calculate `numHashes` different hash functions
    and set corresponding bits to 1.

    When we check whether element is contained in the set, we check if all
    bits are set to 1.
    If they are then the element maybe in the set.
    If they are not then the element is definitely not in the set.

    The probability of false positive can be calculated as follows:
    Let m be the number of bits. Let k be the number of hashes.
    Let n be the number of the elements.

    The probability of 1 bit not being set is (1 - 1/m)^k.
    After inserting n elements this probability becomes (1 - 1/m)^kn = P(ns)
    The probability of element being set after inserting n elements is 1 - P(ns)
    The probability of false positive is approximately (1 - P(ns))^k - the probability of k elements
    being set.
     */
    private val bitSet: BitSet
    private val numHashes: Int

    init {
        bitSet = BitSet(size)
        this.numHashes = numHashes
    }

    fun contains(item: T): Boolean {
        for (index in getIndexes(item)) {
            if (!bitSet.get(index)) return false
        }
        return true
    }

    fun add(item: T) {
        for (index in getIndexes(item)) {
            bitSet.set(index)
        }
    }

    private fun getIndexes(item: T): List<Int> {
        val indexes = mutableListOf<Int>()
        for (subHash in item.md5Hash().chunked(7).take(numHashes)) {
            indexes.add(subHash.toInt(16) % bitSet.size())
        }
        return indexes
    }
}

fun checkBloomFilter() {
    val numHashes = 3
    val size = 1_000_000
    val items = BloomFilter<MD5HashableString>(size, numHashes)

    val numAttempts = 10_000
    repeat(numAttempts) { i ->
        items.add(MD5HashableString(i.toString()))
    }

    var numFalsePositives = 0
    repeat(numAttempts) { i ->
        if (items.contains(MD5HashableString("a$i"))) {
            numFalsePositives++
        }
    }

    println("expected false positive rate = ${getExpectedFalsePositiveRate(size, numHashes, numAttempts)}")
    println("actual false positive rate = ${numFalsePositives.toDouble() / numAttempts}")
}

fun getExpectedFalsePositiveRate(size: Int, numHashes: Int, numElements: Int): Double {
    // this gives an approximation of expected false positive rate
    // it's not 100% correct, but is close enough
    return (1 - (1 - 1.0 / size).pow(numHashes * numElements)).pow(numHashes)
}