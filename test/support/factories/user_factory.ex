defmodule Dominos.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Dominos.Users.User{
          email: Faker.Internet.email()
        }
      end
    end
  end
end
