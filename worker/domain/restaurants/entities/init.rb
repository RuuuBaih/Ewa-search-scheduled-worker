# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

Dir.glob("#{__dir__}/*.rb").sort.each do |file|
  require file
end
