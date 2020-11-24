defmodule DominosWeb.Presence do
  use Phoenix.Presence,
    otp_app: :phat,
    pubsub_server: Dominos.PubSub
end
