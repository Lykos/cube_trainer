module CubeTrainer
  module Training
    # An input item that additionally has a manager that creates
    # sampling info about it.
    ManagedInputItem = Struct.new(:manager, :input_item) do
      def sampling_info
        manager.sampling_info(input_item)
      end
    end
  end
end
