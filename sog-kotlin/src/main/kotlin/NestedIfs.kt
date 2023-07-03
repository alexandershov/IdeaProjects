import java.io.File
import java.io.PrintStream

interface Language {
    fun handle(command: Command)

    fun run(file: File)

    val extension: String
}

enum class Command {
    BEGIN, END, IF, END_IF, PRINT
}

fun exec(command: Array<String>) {
    val process = Runtime.getRuntime().exec(command)

    val exitCode = process.waitFor()
    if (exitCode != 0) {
        System.err.println(process.errorStream.readAllBytes().toString(Charsets.UTF_8))
        throw IllegalStateException("$command exited with $exitCode")
    }
    System.err.println(process.inputStream.readAllBytes().toString(Charsets.UTF_8))
}

fun withoutExtension(file: File): File {
    val dir = file.parentFile
    return File("${dir.path}/${file.nameWithoutExtension}")
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

    override fun run(file: File) {
        exec(arrayOf("javac", "-d", file.parentFile.path, file.path))
        exec(arrayOf("java", "-cp", file.parentFile.path, "ifs"))
    }

    override val extension = "java"
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

    override val extension = "js"

    override fun run(file: File) {
        exec(arrayOf("node", file.path))
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

    override val extension = "rs"

    override fun run(file: File) {
        val executable = withoutExtension(file).path
        exec(arrayOf("rustc", "-o", executable, file.path))
        exec(arrayOf(executable))
    }
}


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

    override val extension = "go"

    override fun run(file: File) {
        exec(arrayOf("go", "run", file.path))
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

    override val extension = "py"

    override fun run(file: File) {
        exec(arrayOf("python3", file.path))
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

    override val extension = "lisp"

    override fun run(file: File) {
        exec(arrayOf("sbcl", "--script", file.path))
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

    override val extension = "cpp"

    override fun run(file: File) {
        val executable = withoutExtension(file).path
        exec(arrayOf("clang++", "-fbracket-depth=1000002", "-o", executable, file.path))
        exec(arrayOf(executable))
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

    override val extension = "hs"

    override fun run(file: File) {
        exec(arrayOf("ghc", file.path))
        exec(arrayOf(withoutExtension(file).path))
    }
}

fun printNestedIfs(languageName: String, n: Int) {
    // Print a $languageName program with $n nested ifs


    val language = languageNamed(languageName)
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

    val originalOut = System.out
    try {
        val tempFile = File.createTempFile("ifs", ".${language.extension}")
        System.setOut(PrintStream(tempFile))
        commands.forEach(language::handle)
        language.run(tempFile)
    } finally {
        System.setOut(originalOut)
    }
}

private fun languageNamed(name: String): Language {
    return when (name) {
        "c++" -> CPlusPlus()
        "python" -> Python()
        "common_lisp" -> CommonLisp()
        "go" -> Go()
        "rust" -> Rust()
        "js" -> Javascript()
        "java" -> Java()
        "haskell" -> Haskell()
        else -> throw IllegalArgumentException("unknown language $name")
    }
}
