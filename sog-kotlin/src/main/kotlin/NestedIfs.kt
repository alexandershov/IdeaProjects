fun printNestedIfs(n: Int) {
    // Print a C++ program with `n` nested ifs
    val commands = ArrayDeque<String>()
    for (i in 1..n) {
        commands.addLast("if")
    }
    commands.addLast("print")
    println("#include <iostream>")
    println("int main() {")
    while (commands.isNotEmpty()) {
        val command = commands.removeFirst()
        when (command) {
            "if" -> {
                println("if (1) {")
                commands.addLast("endif")
            }

            "endif" -> {
                println("}")
            }

            "print" -> {
                println("std::cout << \"hello world\\n\";")
            }

            else -> {
                throw IllegalStateException("unknown command: $command")
            }
        }
    }
    println("}")
}