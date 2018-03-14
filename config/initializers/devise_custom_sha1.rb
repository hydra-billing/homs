require 'digest/sha1'

module Devise
  module Encryptable
    module Encryptors
      # = Sha1
      # Uses the Sha1 hash algorithm to encrypt passwords.
      class Sha1 < Base
        # Generates a default password digest based on stretches, salt, pepper and the
        # incoming password.
        def self.digest(password, stretches, salt, pepper)
          digest = pepper
          stretches.times { digest = self.secure_digest(salt, digest, password, pepper) }
          digest
        end

        private

        # Generate a SHA1 digest joining args. Generated token is something like
        def self.secure_digest(*tokens)
          ::Digest::SHA1.hexdigest(tokens.reverse.flatten.join)
        end
      end
    end
  end
end
