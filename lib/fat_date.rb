# frozen_string_literal: true

require 'active_support'
require "active_support/isolated_execution_state"
require "active_support/core_ext/date"
require "active_support/core_ext/time"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/integer/time"

require 'fat_core/string'

require_relative "fat_date/version"
require_relative "fat_date/patches"
require_relative "fat_date/date"
require_relative "fat_date/datetime"
