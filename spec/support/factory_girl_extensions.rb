module FactoryGirl
  module Syntax
    module Methods
      def create_or_find_user(user_factory)
        User.find_by(email: attributes_for(user_factory)[:email]) || create(user_factory)
      end

      def create_or_find_activity(activity_factory)
        Activity.find_by(slug: attributes_for(activity_factory)[:slug]) || create(activity_factory)
      end
    end
  end
end
