# frozen_string_literal: true

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/app/configuration'
  coverage_dir 'coverage'
end
