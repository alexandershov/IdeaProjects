fun main(args: Array<String>) {
    checkBloomFilter()
    printNestedIfs(if (args.isNotEmpty()) args[0].toInt() else 3)
    // checkKafka() requires running kafka broker, that's why it's commented out
    // checkKafka()

    // checkVirtualThreads intentionally contains infinite loop, that's why it's commented out
    // checkVirtualThreads()
}