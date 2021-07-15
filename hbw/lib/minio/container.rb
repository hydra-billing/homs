require 'aws-sdk-s3'

module Minio
  class Container
    extend Dry::Container::Mixin
    @root = Pathname(__FILE__).realpath.dirname
    singleton_class.send(:attr_reader, :root)

    register(:s3) { Aws::S3::Client.new(stub_responses: Rails.env.test?) }

    register(:minio_adapter) do
      if Rails.env.test?
        require "#{root}/test_adapter.rb"
        Minio::TestAdapter.new
      else
        require "#{root}/adapter.rb"
        Minio::Adapter.new
      end
    end
  end
end
