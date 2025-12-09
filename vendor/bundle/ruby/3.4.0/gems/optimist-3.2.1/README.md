# optimist

http://manageiq.github.io/optimist/

[![Gem Version](https://badge.fury.io/rb/optimist.svg)](http://badge.fury.io/rb/optimist)
[![CI](https://github.com/ManageIQ/optimist/actions/workflows/ci.yaml/badge.svg)](https://github.com/ManageIQ/optimist/actions/workflows/ci.yaml)
[![Code Climate](https://codeclimate.com/github/ManageIQ/optimist.svg)](https://codeclimate.com/github/ManageIQ/optimist)
[![Coverage Status](http://img.shields.io/coveralls/ManageIQ/optimist.svg)](https://coveralls.io/r/ManageIQ/optimist)

## Documentation

- Quickstart: See `Optimist.options` and then `Optimist::Parser#opt`.
- Examples: http://manageiq.github.io/optimist/.
- Wiki: http://github.com/ManageIQ/optimist/wiki

## Description

Optimist is a commandline option parser for Ruby that just gets out of your way.
One line of code per option is all you need to write. For that, you get a nice
automatically-generated help page, robust option parsing, and sensible defaults
for everything you don't specify.

## Features

- Dirt-simple usage.
- Single file. Throw it in lib/ if you don't want to make it a Rubygem dependency.
- Sensible defaults. No tweaking necessary, much tweaking possible.
- Support for long options, short options, subcommands, and automatic type validation and
  conversion.
- Automatic help message generation, wrapped to current screen width.

## Requirements

* A burning desire to write less code.

## Install

* gem install optimist

## Synopsis

```ruby
require 'optimist'
opts = Optimist::options do
  opt :monkey, "Use monkey mode"                    # flag --monkey, default false
  opt :name, "Monkey name", :type => :string        # string --name <s>, default nil
  opt :num_limbs, "Number of limbs", :default => 4  # integer --num-limbs <i>, default to 4
end

p opts # a hash: { :monkey=>false, :name=>nil, :num_limbs=>4, :help=>false }
```

## License

Copyright &copy; 2008-2014 [William Morgan](http://masanjin.net/).

Copyright &copy; 2014 Red Hat, Inc.

Optimist is released under the [MIT License](http://www.opensource.org/licenses/MIT).
