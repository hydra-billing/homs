class OrderSequenceService
  def create
    Sequence.create_for_model(Order, 'ORD', 1)
  end

  def destroy
    Sequence.destroy_for_model(Order)
  end
end
