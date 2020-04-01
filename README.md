# Cobalt

## What is Cobalt?

Cobalt is a build tool for Acucobol applications. Just like Maven for Java, but simpler. It can build COBOL source code,
supporting different configurations per program.
Cobalt is meant to make the COBOL build process more uniform.

## How to install Cobalt?

Cobalt is built as a Linux tool. But it may as well run in Cygwin or MinGW environments. Cobalt depends on Python 3, so
make sure this is installed. Furthermore, Cobalt uses Make internally.

## How does Cobalt work?

Cobalt reads in a Cobalt project file as the build configuration, and then compiles the source code according to the
configuration.

A project file looks like this:

    {
        "projectName": "My Cobol Application",
        "namespace": "org.example",
        "compile": {
            "options": "-x -Cr -D1 -Di -Dz -Zl -Zz -Z91",
            "profiles": [
                {
                    "options": "-x -Ca -Cr -D1 -Di -Dz -Zl -Zz -Z91",
                    "include": [
                        "MyTerminalProgram",
                        "AnotherTerminalProgram"
                    ]
                }
            ]
        },
        "package": {
            "filename": "test-cobol",
            "name": "my-cobol-application",
            "version": "1.0"
        }
    }

As you can see, its contents are just in JSON format.

* `projectName` denotes the name of this project.
* `namespace` declares that the project belongs to the specified namespace. This can be used to organize projects. The
namespace declaration is currently not used by the build tool, but may be used in future versions.
* `compile` declares how the source code should be compiled. The `options` key declares the default compiler options
used to compile programs.
* `profiles` contains an array with compiler profiles for different programs to be compiled. Each element is an object
containing the properties `options` and `include`. The `options` property defines an alternative set of compiler options
used to compile the programs defined in the `include` property, which is an array of strings, each one containing a
program name
* The `package` property declares how the package should be made. Currently, only the `filename` property is used during
the build, and denotes the package filename.

The Cobalt build tool assumes a certain directory structure:

    /
    ├─ cobalt.json
    └─ src/
        ├─ main/
        │   ├─ cobol/
        │   │   └─ copybook/
        │   └ resources/
        └─ test/
            ├─ cobol/
            │   └─ copybook/
            └─ resources/

The project file is located in the root directory. The directory `src/main/cobol` contains all programs to be compiled.
The `src/main/cobol/copybook` directory contains the copybooks. The `src/main/resources` directory contains all
resources necessary to run the programs. The `src/test` directory maintains the same structure as the `src/main` directory, but is intended for test programs to
be run.

When the targets are being built, a `target` directory is created, with a few folders to store intermediate artifacts.
For instance, for each program being built, the `copybook-dependencies` directory contains a file containing a list with
copybook filenames on which the program depends. This is necessary in order to determine whether the source file should
be recompiled. The `objects` subdirectory contains all compiled programs.

If a package is being built, then the package, with a filename specified in the project file, is placed in the `target`
directory.

### More details

Cobalt does not build all programs when it is executed. Instead, only source code which is out of date is being updated.
Internally, Cobalt uses **Make** to determine whether a file should be updated. First, the project file is checked and
a `Makefile` is generated in some cache directory (default `/tmp/.cobalt/cache`). Then Cobalt lets Make build the necessary source files.

# How to use `cobalt`?

Cobalt currently has three built-in targets: `compile`, `package` and `clean`.

* `compile` compiles all source files.
* `package` first compiles all source files, and then generates a package from the compiled files.
* `deploy` first compiles all source files, then generates a deploy-ready package from the compiled files.
* `clean` cleans up the project directory by simply removing the `target` directory.

Use `cobalt --help` to get more details.
