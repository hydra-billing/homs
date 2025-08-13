class Task
  def id
    '12345'
  end

  def homs_order_code
    'ORD-1'
  end
end

describe HBW::TasksController, type: :controller do
  include HBW::TaskHelper

  let(:widget) { HBW::Widget }
  let(:task)   { Task.new }

  it 'Get entity url' do
    expect(entity_url(task, :order)).to eq('/orders/ORD-1?task_id=12345')
  end
end
