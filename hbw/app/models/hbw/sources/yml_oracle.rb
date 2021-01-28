module HBW
  module Sources
    class YMLOracle < Base
      def select(sql, variables, _limit = nil)
        find_response(build_params_key(sql, variables))
      end

      private

      def responses
        @responses ||= YAML.load_file(Rails.root.join('hbw/config/yml_oracle.default.yml'))
      end

      def find_response(hash)
        response = responses[hash] || []

        response.map { |item| item.symbolize_keys }
      end

      def build_params_key(sql, variables)
        Digest::MD5.hexdigest('%s.%s' % [sql, variables.sort_by { |k, _| k }.flatten.join('.')])
      end
    end
  end
end
