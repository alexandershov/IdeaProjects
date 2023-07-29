import jdk.incubator.concurrent.StructuredTaskScope

// structured concurrency is a way to do concurrency with some, ahem, structure
// it's inspired by the nurseries in trio and similar approaches

// the gist of it:
// we add some new entity StructuredTaskScope that can run subtasks
// all subtasks run in the scope of StructuredTaskScope, and we have tree structure of tasks and subtasks
// (subtasks can create their own subtasks etc.)
// we can define different policies of what to do when some subtask fails/succeeds
// this parent-child relationship allows us to have normal-looking tracebacks
// (because there are no freewheeling threads that are owned by nobody)
// and do some stuff based on parent-child ownership
// E.g. if parent is cancelled, it will cancel its children etc.

fun checkStructuredConcurrency() {
    // structured concurrency is a preview feature, we need to run java with additional cmd args:
    // java --enable-preview --add-modules jdk.incubator.concurrent ...

    // StructuredTaskScope implement Closeable interface, so we use, ahem, `use`
    // ShutdownOnFailure will cancel all children threads if some thread throws an exception
    StructuredTaskScope.ShutdownOnFailure().use { scope ->
        // .fork starts a virtual thread
        scope.fork {
            try {
                Thread.sleep(1000)
                // next line will not be executed, because second threads will fail earlier
                // and this thread will get cancelled with InterruptedException
                println("[first thread] i'm done")
            } catch (e: InterruptedException) {
                println("[first thread] got an exception $e")
                throw e
            }
        }

        scope.fork {
            Thread.sleep(500)
            println("[second thread] throwing exception")
            throw Exception("I don't feel like working correctly")
        }
        // we need to call join, otherwise we'll get IllegalStateException at the end of `use`
        // if any thread is failed, then another thread will be automatically cancelled
        // throwIfFailed will propagate exception from any thread

        scope.join().throwIfFailed()
//        we can wait for completion with a deadline
//        here all threads will be cancelled, because deadline < sleep time

        // this block is commented, because the control execution will never get here
//        try {
//            scope.joinUntil(Instant.now().plusMillis(300))
//        } catch (e: TimeoutException) {
//            println("got timeout")
//        }
    }
}


