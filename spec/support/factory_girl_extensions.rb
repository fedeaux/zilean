module FactoryGirl
  module Syntax
    module Methods
      def create_or_find_user(user_factory)
        User.find_by(email: attributes_for(user_factory)[:email]) || create(user_factory)
      end
    end
  end
end
