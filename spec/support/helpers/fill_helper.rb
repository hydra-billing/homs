module Features
  module FillHelper
    def fill_in_datetime_field(name, with:)
      datetime_field = fill_in(name, with: with)
      datetime_field.ancestor('.datetime-picker').sibling('.hbw-datetime-label').click
    end
  end
end
