# ruby_patience_diff

* http://github.com/watt/ruby_patience_diff

## DESCRIPTION:

A Ruby implementation of the Patience diff algorithm.

Patience Diff creates more readable diffs than other algorithms in some cases, particularly when much of the content has changed between the documents being compared. There's a great explanation and example [here][example].

Patience diff was originally written by Bram Cohen and is used in the [Bazaar][bazaar] version control system. This version is loosely based off the Python implementation in Bazaar.

[example]: http://alfedenzo.livejournal.com/170301.html
[bazaar]: http://bazaar.canonical.com/

## INSTALL:

    $ gem install patience_diff

## USAGE:

### Command line:

    $ patience_diff [options] file-a file-b

Run with `--help` to see available options.

### Programmatically:

    left = File.read("/path/to/old").split($RS)
    left_timestamp = File.mtime("/path/to/old")
    right = File.read("/path/to/new").split($RS)
    right_timestamp = File.mtime("/path/to/new")

    differ = PatienceDiff::UnifiedDiffer.new(:context => 10)
    puts differ.diff(left, right, left_file, right_file, left_timestamp, right_timestamp)

## LICENSE:

(The MIT License)

Copyright (c) 2012 Andrew Watt

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
