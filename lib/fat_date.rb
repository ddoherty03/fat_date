# frozen_string_literal: true

require 'active_support'
require 'active_support/testing/time_helpers'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/deep_dup'

require_relative "fat_date/version"
require_relative "fat_date/patches"

module FatDate
  class Error < StandardError; end
  # Your code goes here...
end
