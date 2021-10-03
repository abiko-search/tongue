defmodule Tongue do
  @moduledoc """
  Provides language detection functions

  ## Examples

      iex> Tongue.detect("The octopus is a soft-bodied, eight-armed mollusc of the order Octopoda, with around 300 known species. Along with squids, cuttlefish and nautiloids, they are classed as cephalopods.")
      [en: 0.9999986358008764]
  """

  alias Tongue.Detector

  @doc """
  Detects a language. Returns a keyword of scored languages.

  ## Parameters

    - `text` - a text string

  ## Examples

      iex> Tongue.detect("El microprocesador (o simplemente procesador) es el circuito integrado central más complejo de un sistema informático; a modo de ilustración, se le suele llamar por analogía el «cerebro» de un ordenador.")
      [es: 0.9999977345738683]

  """

  @spec detect(String.t()) :: keyword(char())
  def detect(text) do
    Detector.detect(text)
  end

  @doc """
  Returns the list of languages which Tongue is able to detect
  """

  @spec languages() :: list(atom)
  def languages do
    Detector.languages()
  end
end
