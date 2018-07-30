defmodule Tongue.Data do
  @moduledoc false

  @messages "./priv/messages.binary"
            |> File.read!()
            |> :erlang.binary_to_term()

  @blocks "./priv/unicode_blocks.binary"
          |> File.read!()
          |> :erlang.binary_to_term()

  @profiles "./priv/profiles.binary"
            |> File.read!()
            |> :erlang.binary_to_term()

  def ngram_frequencies do
    @profiles.ngrams_frequencies
  end

  def languages do
    @profiles.languages
  end

  def messages(id), do: @messages[id]

  def blocks do
    @blocks
  end
end
