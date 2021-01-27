module HasSequencedColumn
  extend ActiveSupport::Concern

  module ClassMethods
    # rubocop:disable Naming/PredicateName
    def has_sequenced_column(column = :code)
      class_attribute :sequenced_column

      self.sequenced_column = column

      before_create do
        self[column] = Sequence.nextval(self.class)
      end
    end
    # rubocop:enable Naming/PredicateName
  end
end
