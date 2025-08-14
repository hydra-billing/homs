class Task
  def id
    '12345'
  end

  # rubocop:disable Naming/MethodName
  def homsOrderCode
    'ORD-1'
  end
  # rubocop:enable Naming/MethodName
end

describe HBW::TasksController, type: :controller do
  include HBW::TaskHelper

  let(:widget) { HBW::Widget }
  let(:task)   { Task.new }

  it 'Get entity url' do
    expect(entity_url(task, :order)).to eq('/orders/ORD-1?task_id=12345')
  end
end
