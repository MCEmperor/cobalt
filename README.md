# Cobalt

## What is Cobalt?

Cobalt is a build tool for ACUCOBOL applications. Just like Maven for Java, but simpler. It can build COBOL source code,
supporting different configurations per program. Cobalt is meant to make the COBOL build process more uniform.

## How to build Cobalt?

Cobalt is built using the `Makefile` file within this repository. Currently, the building process only supports to make
a Debian package. The build process uses [fpm](https://github.com/jordansissel/fpm) to build the Debian package, and fpm
requires `ruby` and `gem`.

In order to install all the dependencies necessary to build Cobalt, use the following:

```bash
apt-get update
apt-get install -y binutils gem make ruby
gem install fpm
```

To build a Debian package, use `make package-debian`. The package will be located in the `target` directory.

## How to install Cobalt?

Cobalt is built as a Linux tool. But it may as well run in Cygwin or MinGW environments.

In order to install Cobalt, make sure to get the Debian package file. Assuming the path to the package is
`./cobalt.deb`, install Cobalt using the following:

```bash
apt-get update && apt-get install -y ./cobalt.deb
```

## How does Cobalt work?

Cobalt reads in a Cobalt project file as the build configuration, and then compiles the source code according to the
configuration. Cobalt internally uses Make to decide which files must be built.

A project file looks like this:

```json
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
        ],
        "fd": true
    },
    "package": {
        "filename": "test-cobol",
        "name": "my-cobol-application",
        "version": "1.0"
    },
    "deploy": {
        "fingerprint": "git-commit-hash"
    }
}
```

As you can see, its contents are just in JSON format.

* `projectName` denotes the name of this project.
* `namespace` declares that the project belongs to the specified namespace. This can be used to organize projects. The
namespace declaration is currently not used by the build tool, but may be used in future versions.
* `compile` declares how the source code should be compiled.
    * The `options` key declares the default compiler options used to compile programs.
    * `profiles` contains an array with compiler profiles for different programs to be compiled. Each element is an
        object containing the properties `options` and `include`. The `options` property defines an alternative set of
        compiler options used to compile the programs defined in the `include` property, which is an array of strings,
        each one containing a program name.
    * The `fd` key is a boolean, and denotes whether *xfd* files should be generated.
* The `package` property declares how the package should be made. Currently, only the `filename` property is used during
the build, and denotes the package filename.
* The `deploy` property declares how the deploy-ready package should be made. Currently, the filename is the same as the
filename declared within the package property. The `fingerprint` property declares the *fingerprint provider*. A
fingerprint provider is a mechanism to provide some form of identification for the package to be built. The default
provider is `git-commit-hash`, which takes the Git commit hash of the current folder under version control, and injects
it into the comment section of the package.

The Cobalt build tool assumes a certain directory structure:

```none
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
```

The project file is located in the root directory. The directory `src/main/cobol` contains all programs to be compiled.
The `src/main/cobol/copybook` directory contains the copybooks. The `src/main/resources` directory contains all
resources necessary to run the programs. The `src/test` directory maintains the same structure as the `src/main`
directory, but is intended for test programs to be run.

When the targets are being built, a `target` directory is created, with a few folders to store intermediate artifacts.
For instance, for each program being built, the `copybookdependencies` directory contains a file containing a list with
copybook filenames on which the program depends. This is necessary in order to determine whether the source file should
be recompiled. The `objects` subdirectory contains all compiled programs.

If a package is being built, then the package, with a filename specified in the project file, is placed in the `target`
directory.

### More details

Cobalt does not build all programs when it is executed. Instead, only source code which is out of date is being updated.
Internally, Cobalt uses **Make** to determine whether a file should be updated. First, the project file is checked and
a `Makefile` is generated in some cache directory for the project (default `/tmp/.cobalt/cache/project_dir_hash/`, where
*project_dir_hash* is a hash associated with the directory of the project). Then Cobalt lets Make build the necessary
source files.

# How to use Cobalt?

Cobalt currently has four built-in targets: `compile`, `package`, `deploy` and `clean`.

* `compile` compiles all source files.
* `package` first compiles all source files, and then generates a package from the compiled files.
* `deploy` first compiles all source files, then generates a deploy-ready package from the compiled files.
* `clean` cleans up the project directory by simply removing the `target` directory.

Use `cobalt --help` to get more details.
