# frozen_string_literal: true

module FatDate
  module DateTime
    # Format as an ISO string of the form `YYYY-MM-DD`.
    # @return [String]
    def iso
      strftime('%Y-%m-%dT%H:%M:%S.%3N%:%z')
    end

    module ClassMethods
      # Convert a date-like object to DateTime, using midnight for date-only
      # inputs and preserving time components and offsets when present.
      # @param dat [String, Date, DateTime, Time] the object to be converted
      # @return [DateTime]
      def ensure(dat)
        ::Date.ensure(dat).to_datetime
      end

      alias_method :ensure_datetime, :ensure
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

# Include the FatDate instance and class methods in DateTime.
class DateTime
  include FatDate::DateTime
end
