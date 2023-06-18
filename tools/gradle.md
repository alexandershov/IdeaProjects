## Gradle cheatsheet

Gradle is a build tool.
You define tasks and gradle resolve dependencies etc.

Kotlin+Gradle tutorial is [here](https://docs.gradle.org/current/samples/sample_building_kotlin_applications.html)

Install gradle
```shell
brew install gradle
```

Initialize gradle project
```shell
cd gradle-demo
# 
gradle init
```

`gradle init` will generate an application skeleton.
It will generate 'gradlew' file which is a Gradle Wrapper that is an entry point for executing gradle tasks.


Build and run an application
```shell
cd gradle-demo
./gradlew run
```

List all gradle tasks
```shell
cd gradle-demo
./gradlew tasks
```


Bundle application with all its dependencies into app.zip
```shell
cd gradle-demo
./gradlew build
ls ./app/build/distributions/app.zip
```

You can unzip app.zip and run bin/app.
This archive contains all your app dependencies.
