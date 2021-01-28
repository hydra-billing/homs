class Sequence < ActiveRecord::Base
  validates :name, uniqueness: true
  validates :prefix, uniqueness: true
  validates :start, numericality: {greater_than: 0}

  def self.nextval(model)
    sequence = find_by_name!(model_sequence_name(model))

    val = connection.execute(
      "SELECT nextval('#{sequence.name}')"
    )[0]['nextval']

    "#{sequence.prefix}-#{val}"
  end

  def self.model_sequence_name(model)
    "#{model.model_name.plural}_#{model.sequenced_column}"
  end

  def self.create_sequence(name, start)
    connection.execute <<-SQL
      CREATE SEQUENCE #{name} START #{start};
    SQL
  end

  def self.destroy_sequence(name)
    connection.execute <<-SQL
      DROP SEQUENCE IF EXISTS #{name};
    SQL
  end

  def self.create_for_model(model, prefix, start = 1)
    transaction do
      create(name: model_sequence_name(model), prefix: prefix, start: start)
      create_sequence(model_sequence_name(model), start)
    end
  end

  def self.destroy_for_model(model)
    transaction do
      find_by_name(model_sequence_name(model)).try(:destroy)
      destroy_sequence(model_sequence_name(model))
    end
  end
end
