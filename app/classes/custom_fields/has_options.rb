module CustomFields
  module HasOptions
    attr_accessor :options
    delegate :[], to: :options
  end
end
