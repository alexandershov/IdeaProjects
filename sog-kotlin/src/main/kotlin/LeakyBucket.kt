import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.atomic.AtomicInteger
import kotlin.concurrent.thread
import kotlin.random.Random
import kotlin.random.nextInt

/*
  Leaky bucket is a tool to shape traffic.

  Metaphor is having a bucket that leaks with a constant rate.
  Inbound water can be accepted (is there's a room) or rejected (if the bucket is full).
  Leaky bucket outputs traffic that doesn't exceed some constant rate.
  Inbound traffic can have burst, but that doesn't make outbound traffic to have bursts.
 */

/* There is also a token bucket.
   Tokens are added to the bucket at the constant rate.

   Each incoming request spends some amount of tokens.
   If there's not enough tokens, then request is rejected.

   The difference between token bucket and leaky bucket is that
   token bucket allows bursts in outgoing traffic (e.g. when basket is full of tokens
   and we spend them all really fast because of the surge in the traffic)
 */
fun checkLeakyBucket() {
    val size = AtomicInteger(0)
    val maxSize = 1000
    val numItems = AtomicInteger(0)
    val numRejections = AtomicInteger(0)

    val queue = ConcurrentLinkedQueue<String>()
    val producer = thread(start = true) {
        while (numItems.get() < 10000) {
            val curNumItems = Random.nextInt(18..28)
            repeat(curNumItems) {
                if (size.get() == maxSize) { // bucket is full, reject
                    numRejections.incrementAndGet()
                } else {  // add to bucket
                    queue.add("event ${size.get()}")
                    size.incrementAndGet()
                }

            }
            Thread.sleep(10)
        }
    }

    val bucket = thread(start = true) {
        // This bucket leaks with the rate 2 events per millisecond
        while (numItems.get() < 10000) {
            for (i in 1..20) {
                queue.poll() ?: break
                size.decrementAndGet()
                numItems.incrementAndGet()
            }
            Thread.sleep(10)
        }
    }
    producer.join()
    bucket.join()
    println("size = $size, numItems = $numItems, numRejections = $numRejections")
}