defmodule Tongue.App do
  @moduledoc false

  use Application

  def start(_, _) do
    children = [
      Tongue.Detector
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
