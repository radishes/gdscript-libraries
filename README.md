# gdscript-libraries

A collection of general-purpose helpers for Godot 4 gdscript. Each script and method is self-documented.

## Usage

### Static helper methods

Most of these scripts contain static helper methods, which are accessible by using the `class\_name`
of the script. These scripts are immediately accessible within your project as soon as they're added.
For example, the method `save\_file()` in `file\_lib.gd` can be called with `FileLib.save\_file()`.

### Singleton scripts

`log\_lib.gd` and `random.gd` should be imported as global singletons and accessed under their singleton name.

### Project structure

In my projects, I create a folder in the project called `lib` and drop whichever library scripts I
want to use into that folder.

## License

Unlicense https://unlicense.org/
