class ListOrdersFilter
  include DatetimeFormat

  class EmptyUser < User
    def id
      'empty'
    end

    def full_name
      I18n.t('users.empty')
    end

    def save(*)
      raise NotImplementedError
    end
  end

  class << self
    def empty_user
      @empty_user ||= EmptyUser.new
    end
  end

  module Filters
    extend self

    def filter_by_date(rel, dates)
      { created_at_from: 'created_at >= ?',
        created_at_to:   'created_at <= ?' }.reduce(rel) do |r, (attr, condition)|
        if dates[attr].present?
          r.where(condition, dates[attr])
        else
          r
        end
      end
    end

    def filter_by_user_id(rel, value)
      has_empty = value.find { |v| v == 'empty' }
      values = value - %w(empty)

      if has_empty && values.present?
        rel.where('(user_id in (?) or user_id is null)', values)
      elsif has_empty
        rel.where(user_id: nil)
      else
        rel.where(user_id: values)
      end
    end

    def filter_by(rel, column, value)
      rel.where(column => value)
    end

    def filter_with_dispatch(rel, column, value)
      if value.present?
        if respond_to?('filter_by_%s' % column)
          public_send('filter_by_%s' % column, rel, value)
        else
          filter_by(rel, column, value)
        end
      else
        rel
      end
    end
  end

  EMPTY_USER_ID = 'empty'

  delegate :empty_user, to: :'self.class'

  attr_reader :current_user, :params

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def list_orders(relation = Order.all)
    %w(state order_type_id user_id archived).reduce(Filters.filter_by_date(relation, filter_values)) do |rel, column|
      Filters.filter_with_dispatch(rel, column, filter_values[column])
    end
  end

  def filter_values
    @filter_values ||= params.slice(*%w(state order_type_id archived user_id)).merge(dates)
  end

  def dates
    @dates ||=
      begin
        now = Time.current
        created_at_from = parse_date_value(params[:created_at_from], (now - 1.day).beginning_of_day).try(:change, {offset: Time.zone.formatted_offset})
        created_at_to = parse_date_value(params[:created_at_to], now.end_of_day).try(:change, {offset: Time.zone.formatted_offset})

        { created_at_from: created_at_from,
          created_at_to: created_at_to }.with_indifferent_access
      end
  end

  def users
    (params[:user_id] || []).map do |user_id|
      if user_id == EMPTY_USER_ID
        empty_user
      elsif user_id == current_user.id.to_s
        current_user
      else
        User.find(user_id)
      end
    end
  end

  private

  def parse_date_value(value, default)
    if value.present?
      DateTime.strptime(value, datetime_format)
    elsif !filter?
      default
    end
  end

  def filter?
    !!params[:filter]
  end
end
