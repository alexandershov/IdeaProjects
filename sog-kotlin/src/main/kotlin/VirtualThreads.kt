import java.time.LocalTime

@Suppress("ControlFlowWithEmptyBody")
fun checkVirtualThreads() {
    val parallelism = System.getProperty("jdk.virtualThreadScheduler.parallelism")
    val maxPoolSize = System.getProperty("jdk.virtualThreadScheduler.maxPoolSize")
    val minRunnable = System.getProperty("jdk.virtualThreadScheduler.minRunnable")
    println("parallelism = $parallelism, maxPoolSize = $maxPoolSize, minRunnable = $minRunnable")

    val busyThread = Thread.ofVirtual().name("my thread").start {

        while (true) {

        }
    }

    /*
    If we start JVM with only one platform thread:
     -Djdk.virtualThreadScheduler.parallelism=1
     -Djdk.virtualThreadScheduler.maxPoolSize=1
     -Djdk.virtualThreadScheduler.minRunnable=1
    then printingThread will never start executing, because Java's virtual threads are cooperative

    Good write-up about it is here: https://blog.rockthejvm.com/ultimate-guide-to-java-virtual-threads/
     */
    val printingThread = Thread.ofVirtual().name("my thread").start {
        println("${LocalTime.now()} i am a virtual thread!")
    }

    busyThread.join()
    printingThread.join()
}