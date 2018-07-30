defmodule Tongue do
  @moduledoc """
  Provides language detection functions

  ## Examples

      iex> Tongue.detect("The octopus is a soft-bodied, eight-armed mollusc of the order Octopoda, with around 300 known species. Along with squids, cuttlefish and nautiloids, they are classed as cephalopods.")
      [en: 0.9999986358008764]
  """

  alias Tongue.{Data, Detector}

  @doc """
  Detects a language. Returns a keyword of scored languages.
  
  ## Parameters

    - `text` - a text string
    - `languages` - a tuple generated by `Tongue.select_languages/1`
  
  ## Examples
  
      iex> Tongue.detect("El microprocesador (o simplemente procesador) es el circuito integrado central más complejo de un sistema informático; a modo de ilustración, se le suele llamar por analogía el «cerebro» de un ordenador.", subset)
      [es: 0.9999977345738683]

  """

  @spec detect(String.t(), tuple()) :: keyword(char())
  def detect(text, languages \\ nil)

  def detect(text, nil) do
    Detector.detect(text, Data.languages(), Data.ngram_frequencies())
  end

  def detect(text, selected_languages) do
    {languages, ngram_frequencies} = selected_languages
    Detector.detect(text, languages, ngram_frequencies)
  end

  @doc """
  Returns the list of languages which Tongue is able to detect
  """

  @spec languages() :: list(atom)
  def languages do
    Data.languages()
  end

  @doc """
  Strips built-in dataset to selected languages
  
  ## Parameters

    - `languages` - a list of languages you would like to detect
  
  ## Examples
  
      iex> subset = Tongue.select_languages(~w(ru en es fr)a)
      iex> Tongue.detect("Le puits du Magny est l'un des principaux puits des houillères de Ronchamp, situé sur le territoire de la commune de Magny-Danigon", subset)
      [fr: 0.9999968121112444]

  """

  @spec select_languages(list(atom)) :: tuple()
  def select_languages(languages) do
    builtin_languages = Data.languages()

    ngram_frequencies = Enum.into(Data.ngram_frequencies(), %{}, fn {ngram, frequencies} ->
      {_, frequencies} =
        builtin_languages
        |> Enum.zip(frequencies)
        |> Enum.filter(fn {language, _} -> language in languages end)
        |> Enum.unzip

      {ngram, frequencies}
    end)

    {Enum.sort(languages), ngram_frequencies}
  end
end
