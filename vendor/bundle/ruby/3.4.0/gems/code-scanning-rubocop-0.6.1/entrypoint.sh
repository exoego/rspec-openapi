#!/bin/sh

set -x

cd $GITHUB_WORKSPACE

# Install correct bundler version
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"

bundle add code-scanning-rubocop --version 0.2.0  --skip-install

bundle install
bundle exec rubocop --require code_scanning --format CodeScanning::SarifFormatter -o rubocop.sarif

if [ ! -f rubocop.sarif ]; then
    exit 1
else
    exit 0
fi
