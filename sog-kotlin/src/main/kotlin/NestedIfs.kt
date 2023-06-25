interface Language {
    fun handle(command: Command)
}

enum class Command {
    BEGIN, END, IF, END_IF, PRINT
}

class Java : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.IF -> println("if (true) {")
            Command.BEGIN -> {
                println("class ifs {")
                println("public static void main(String[] args) {")
            }

            Command.END -> {
                println("}")  // close void main()
                println("}")  // close class ifs
            }

            Command.END_IF -> println("}")
            Command.PRINT -> println("System.out.println(\"hello world\");")
        }
    }
}

class Javascript : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> {}
            Command.END -> {}
            Command.IF -> println("if (true) {")
            Command.END_IF -> println("}")
            Command.PRINT -> println("console.log(\"hello world\");")
        }
    }
}

class Rust : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> println("fn main() {")
            Command.END -> println("}")
            Command.IF -> println("if true {")
            Command.END_IF -> println("}")
            Command.PRINT -> println("print!(\"hello world\")")
        }
    }
}


// TODO: make language interface less verbose
class Go : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> {
                println("package main")
                println("import \"fmt\"")
                println("func main() {")
            }

            Command.END -> println("}")
            Command.IF -> println("if true {")
            Command.END_IF -> println("}")
            Command.PRINT -> println("fmt.Println(\"hello world\")")
        }
    }
}

class Python : Language {
    private var indentationLevel = 0

    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> {
                println("def main():")
                indentationLevel++
            }

            Command.END -> println("if __name__ == '__main__': main()")
            Command.IF -> {
                println("${indentation()}if 1:")
                indentationLevel += 1
            }

            Command.END_IF -> indentationLevel--
            Command.PRINT -> println("${indentation()}print('hello world')")
        }
    }

    private fun indentation(): String {
        return " ".repeat(indentationLevel * 4)
    }
}

class CommonLisp : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> {}
            Command.END -> {}
            Command.IF -> print("(if t ")
            Command.END_IF -> print(")")
            Command.PRINT -> print("(print \"hello world\")")
        }
    }
}

class CPlusPlus : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> {
                println("#include <iostream>")
                println("int main() {")
            }

            Command.END -> println("}")
            Command.IF -> println("if (1) {")
            Command.END_IF -> println("}")
            Command.PRINT -> println("std::cout << \"hello world\\n\";")
        }
    }
}

class Haskell : Language {
    override fun handle(command: Command) {
        when (command) {
            Command.BEGIN -> println("main = putStrLn ")
            Command.END -> {}
            Command.IF -> println(" (if True then")
            Command.END_IF -> println(" else \"\")")
            Command.PRINT -> println(" \"hello world\"")
        }
    }
}

fun printNestedIfs(languageName: String, n: Int) {
    val language = languageNamed(languageName)
    // Print a C++ program with `n` nested ifs
    val commands = mutableListOf<Command>()
    commands.add(Command.BEGIN)
    repeat(n) {
        commands.add(Command.IF)
    }
    commands.add(Command.PRINT)

    repeat(n) {
        commands.add(Command.END_IF)
    }

    commands.add(Command.END)

    commands.forEach(language::handle)
}

private fun languageNamed(languageName: String): Language {
    return when (languageName) {
        "c++" -> CPlusPlus()
        "python" -> Python()
        "common_lisp" -> CommonLisp()
        "go" -> Go()
        "rust" -> Rust()
        "js" -> Javascript()
        "java" -> Java()
        "haskell" -> Haskell()
        else -> throw IllegalArgumentException("unknown language $languageName")
    }
}
