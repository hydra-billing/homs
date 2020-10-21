module HBW
  class TranslationsController < BaseController
    def index
      render json: BPTranslationsBuilder.call
    end
  end
end
