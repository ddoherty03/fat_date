# frozen_string_literal: true

# Provide #positive? and #negative? for older versions of Ruby.
unless 2.respond_to?(:positive?)
  # Patch Numeric
  class Numeric
    def positive?
      self > 0
    end
  end
end

unless 2.respond_to?(:negative?)
  # Patch Numeric
  class Numeric
    def negative?
      self < 0
    end
  end
end
