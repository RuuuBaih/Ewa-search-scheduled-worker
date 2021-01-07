# frozen_string_literal: true

%w[entities mappers repositories]
  .each do |folder|
    require_relative "#{folder}/init"
  end
