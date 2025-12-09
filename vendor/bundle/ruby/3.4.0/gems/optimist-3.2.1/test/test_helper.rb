$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

unless ENV['MUTANT']
  begin
  require "coveralls"
  Coveralls.wear! do
    add_filter '/test/'
  end
  rescue LoadError
  end
end

begin
  require "pry"
rescue LoadError
end

require 'minitest/autorun'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

require 'optimist'
