import kotlin.system.exitProcess

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println("no command passed, exiting")
        exitProcess(1)
    }
    when (val command = args[0]) {
        "bloomFilter" -> {
            checkBloomFilter()
        }

        "kafka" -> {
            // this requires running kafka broker
            checkKafka()
        }

        "virtualThreads" -> {
            checkVirtualThreads()
        }

        "nestedIfs" -> {
            val (languageName, n) = Pair(args[1], args[2].toInt())
            printNestedIfs(languageName, n)
        }

        else -> {
            println("unknown command $command")
            exitProcess(1)
        }
    }
}