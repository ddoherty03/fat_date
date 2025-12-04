module FatDate
  module DateTime
    # Format as an ISO string of the form `YYYY-MM-DD`.
    # @return [String]
    def iso
      strftime('%Y-%m-%dT%H:%M:%S.%3N%:%z')
    end
  end
end

# Include the FatDate methods in Date and extend the Date class methods with
# the FatDate::ClassMethods methods.
class DateTime
  include FatDate::DateTime
end
