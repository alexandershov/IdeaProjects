interface Language {
    fun onIf()
    fun onEndIf()
    fun onPrint()
    fun onBegin()
    fun onEnd()
}

class JavaLanguage : Language {
    override fun onIf() {
        println("if (true) {")
    }

    override fun onEndIf() {
        println("}")
    }

    override fun onPrint() {
        println("System.out.println(\"hello world\");")
    }

    override fun onBegin() {
        println("class ifs {")
        println("public static void main(String[] args) {")
    }

    override fun onEnd() {
        println("}")
        println("}")
    }

}

class JsLanguage : Language {
    override fun onIf() {
        println("if (true) {")
    }

    override fun onEndIf() {
        println("}")
    }

    override fun onPrint() {
        println("console.log(\"hello world\");")
    }

    override fun onBegin() {

    }

    override fun onEnd() {

    }

}

class RustLanguage : Language {
    override fun onIf() {
        println("if true {")
    }

    override fun onEndIf() {
        println("}")
    }

    override fun onPrint() {
        println("print!(\"hello world\")")
    }

    override fun onBegin() {
        println("fn main() {")
    }

    override fun onEnd() {
        println("}")
    }

}


// TODO: make language interface less verbose
class GoLanguage : Language {
    override fun onIf() {
        println("if true {")
    }

    override fun onEndIf() {
        println("}")
    }

    override fun onPrint() {
        println("fmt.Println(\"hello world\")")
    }

    override fun onBegin() {
        println("package main")
        println("import \"fmt\"")
        println("func main() {")
    }

    override fun onEnd() {
        println("}")
    }

}

class PythonLanguage : Language {
    private var indentationLevel = 0
    override fun onIf() {
        println("${indentation()}if 1:")
        indentationLevel += 1
    }

    override fun onEndIf() {
        indentationLevel--
    }

    override fun onPrint() {
        println("${indentation()}print('hello world')")
    }

    override fun onBegin() {
        println("def main():")
        indentationLevel++
    }

    override fun onEnd() {
        println("if __name__ == '__main__': main()")
    }

    private fun indentation(): String {
        return " ".repeat(indentationLevel * 4)
    }

}

class CommonLispLanguage : Language {
    override fun onIf() {
        print("(if t ")
    }

    override fun onEndIf() {
        print(")")
    }

    override fun onPrint() {
        print("(print \"hello world\")")
    }

    override fun onBegin() {
    }

    override fun onEnd() {
    }

}

class CppLanguage : Language {
    override fun onIf() {
        println("if (1) {")
    }

    override fun onEndIf() {
        println("}")
    }

    override fun onPrint() {
        println("std::cout << \"hello world\\n\";")
    }

    override fun onBegin() {
        println("#include <iostream>")
        println("int main() {")
    }

    override fun onEnd() {
        println("}")
    }

}

fun printNestedIfs(languageName: String, n: Int) {
    val language = when (languageName) {
        "c++" -> CppLanguage()
        "python" -> PythonLanguage()
        "common_lisp" -> CommonLispLanguage()
        "go" -> GoLanguage()
        "rust" -> RustLanguage()
        "js" -> JsLanguage()
        "java" -> JavaLanguage()
        else -> throw IllegalArgumentException("unknown language $languageName")
    }
    // Print a C++ program with `n` nested ifs
    val commands = ArrayDeque<String>()
    commands.addFirst("begin")
    for (i in 1..n) {
        commands.addLast("if")
    }
    commands.addLast("print")
    commands.addLast("end")

    while (commands.isNotEmpty()) {
        when (val command = commands.removeFirst()) {
            "begin" -> {
                language.onBegin()
            }

            "if" -> {
                language.onIf()
                commands.addLast("endif")
            }

            "endif" -> {
                language.onEndIf()
            }

            "print" -> {
                language.onPrint()
            }

            "end" -> {
                language.onEnd()
            }

            else -> {
                throw IllegalStateException("unknown command: $command")
            }
        }
    }

}

