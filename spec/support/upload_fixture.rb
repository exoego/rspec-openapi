# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

# A tiny PNG for the file-upload examples of the Rails, Hanami and Roda apps.
#
# The generated documents record an uploaded file by its basename, so the file
# has to keep the name test.png. Spec files run side by side (see
# scripts/parallel_rspec), and they used to write test.png into the repository
# root, where concurrent runs would read a half-written file. Each process now
# gets its own directory instead.
module UploadFixture
  DATA = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
  QBoAAAAASUVORK5CYII='

  def self.path
    @path ||= begin
      dir = Dir.mktmpdir('rspec-openapi-upload')
      at_exit { FileUtils.remove_entry(dir, true) }
      File.join(dir, 'test.png').tap { |path| File.binwrite(path, DATA.unpack1('m')) }
    end
  end
end
