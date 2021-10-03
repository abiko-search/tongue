defmodule Tongue.Detector do
  @moduledoc false

  import Nx.Defn

  use GenServer

  @n_gram 3
  @n_trial 7
  @alpha_default 0.5
  @alpha_width 0.05
  @iteration_limit 1000
  @probability_threshold 0.1
  @convolution_threshold 0.99999
  @base_frequency 10_000

  @messages "priv/messages.binary"
            |> File.read!()
            |> :erlang.binary_to_term()

  @blocks "priv/unicode_blocks.binary"
          |> File.read!()
          |> :erlang.binary_to_term()

  @builtin_languages "priv/profiles.binary"
                     |> File.read!()
                     |> :erlang.binary_to_term()
                     |> Map.get(:languages)

  @latin1_excluded @messages["NGram.LATIN1_EXCLUDE"]

  @normalized_vi_chars ~w(NORMALIZED_VI_CHARS_0300 NORMALIZED_VI_CHARS_0301 NORMALIZED_VI_CHARS_0303
                          NORMALIZED_VI_CHARS_0309 NORMALIZED_VI_CHARS_0323)
                       |> Enum.map(&@messages[&1])

  @to_normalize_chars @messages["TO_NORMALIZE_VI_CHARS"]
  @dmark_class @messages["DMARK_CLASS"]

  # CJK Kanji Normalization mapping

  @cjk_map ~w(NGram.KANJI_1_0  NGram.KANJI_1_2  NGram.KANJI_1_4  NGram.KANJI_1_8  NGram.KANJI_1_11
              NGram.KANJI_1_12 NGram.KANJI_1_13 NGram.KANJI_1_14 NGram.KANJI_1_16 NGram.KANJI_1_18
              NGram.KANJI_1_22 NGram.KANJI_1_27 NGram.KANJI_1_29 NGram.KANJI_1_31 NGram.KANJI_1_35
              NGram.KANJI_2_0  NGram.KANJI_2_1  NGram.KANJI_2_4  NGram.KANJI_2_9  NGram.KANJI_2_10
              NGram.KANJI_2_11 NGram.KANJI_2_12 NGram.KANJI_2_13 NGram.KANJI_2_15 NGram.KANJI_2_16
              NGram.KANJI_2_18 NGram.KANJI_2_21 NGram.KANJI_2_22 NGram.KANJI_2_23 NGram.KANJI_2_28
              NGram.KANJI_2_29 NGram.KANJI_2_30 NGram.KANJI_2_31 NGram.KANJI_2_32 NGram.KANJI_2_35
              NGram.KANJI_2_36 NGram.KANJI_2_37 NGram.KANJI_2_38 NGram.KANJI_3_1  NGram.KANJI_3_2
              NGram.KANJI_3_3  NGram.KANJI_3_4  NGram.KANJI_3_5  NGram.KANJI_3_8  NGram.KANJI_3_9
              NGram.KANJI_3_11 NGram.KANJI_3_12 NGram.KANJI_3_13 NGram.KANJI_3_15 NGram.KANJI_3_16
              NGram.KANJI_3_18 NGram.KANJI_3_19 NGram.KANJI_3_22 NGram.KANJI_3_23 NGram.KANJI_3_27
              NGram.KANJI_3_29 NGram.KANJI_3_30 NGram.KANJI_3_31 NGram.KANJI_3_32 NGram.KANJI_3_35
              NGram.KANJI_3_36 NGram.KANJI_3_37 NGram.KANJI_3_38 NGram.KANJI_4_0  NGram.KANJI_4_9
              NGram.KANJI_4_10 NGram.KANJI_4_16 NGram.KANJI_4_17 NGram.KANJI_4_18 NGram.KANJI_4_22
              NGram.KANJI_4_24 NGram.KANJI_4_28 NGram.KANJI_4_34 NGram.KANJI_4_39 NGram.KANJI_5_10
              NGram.KANJI_5_11 NGram.KANJI_5_12 NGram.KANJI_5_13 NGram.KANJI_5_14 NGram.KANJI_5_18
              NGram.KANJI_5_26 NGram.KANJI_5_29 NGram.KANJI_5_34 NGram.KANJI_5_39 NGram.KANJI_6_0 
              NGram.KANJI_6_3  NGram.KANJI_6_9  NGram.KANJI_6_10 NGram.KANJI_6_11 NGram.KANJI_6_12
              NGram.KANJI_6_16 NGram.KANJI_6_18 NGram.KANJI_6_20 NGram.KANJI_6_21 NGram.KANJI_6_22
              NGram.KANJI_6_23 NGram.KANJI_6_25 NGram.KANJI_6_28 NGram.KANJI_6_29 NGram.KANJI_6_30
              NGram.KANJI_6_32 NGram.KANJI_6_34 NGram.KANJI_6_35 NGram.KANJI_6_37 NGram.KANJI_6_39
              NGram.KANJI_7_0  NGram.KANJI_7_3  NGram.KANJI_7_6  NGram.KANJI_7_7  NGram.KANJI_7_9
              NGram.KANJI_7_11 NGram.KANJI_7_12 NGram.KANJI_7_13 NGram.KANJI_7_16 NGram.KANJI_7_18
              NGram.KANJI_7_19 NGram.KANJI_7_20 NGram.KANJI_7_21 NGram.KANJI_7_23 NGram.KANJI_7_25
              NGram.KANJI_7_28 NGram.KANJI_7_29 NGram.KANJI_7_32 NGram.KANJI_7_33 NGram.KANJI_7_35
              NGram.KANJI_7_37)
           |> Enum.flat_map(fn key ->
             message = @messages[key]
             representative = List.first(message)
             Enum.map(message, &{&1, representative})
           end)
           |> Map.new()

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {languages, ngram_frequencies} =
      :tongue
      |> Application.app_dir("priv/profiles.binary")
      |> File.read!()
      |> :erlang.binary_to_term()
      |> Map.get(:ngrams_frequencies)
      |> subset(Application.get_env(:tongue, :languages))

    ngram_frequencies =
      ngram_frequencies
      |> Enum.map(fn {ngram, frequencies} -> {ngram, Nx.from_binary(frequencies, {:f, 32})} end)
      |> Enum.into(%{})

    {:ok, {languages, ngram_frequencies}}
  end

  def detect(text) do
    GenServer.call(__MODULE__, {:detect, text})
  end

  def languages() do
    GenServer.call(__MODULE__, :languages)
  end

  def handle_call(:languages, _from, {languages, ngram_frequencies}) do
    {:reply, languages, {languages, ngram_frequencies}}
  end

  def handle_call({:detect, text}, _from, {languages, ngram_frequencies}) do
    # Cleaning text to detect
    # (eliminate URL, e-mail address and Latin sentence if it is not written in Latin alphabet).

    probabilities =
      text
      |> String.replace(~r(https?://[-_.?&~;+=/#0-9A-Za-z]{1,2076}), " ")
      |> String.replace(~r([-_.0-9A-Za-z]{1,64}@[-_0-9A-Za-z]{1,255}[-_.0-9A-Za-z]{1,255}), " ")
      |> String.to_charlist()
      |> clean
      |> normalize
      |> extract_ngrams(ngram_frequencies)
      |> calculate_probabilities_x(languages, ngram_frequencies)
      |> filter_probabilities(languages)

    {:reply, probabilities, {languages, ngram_frequencies}}
  end

  def subset(ngram_frequencies, languages) when is_nil(languages) do
    {@builtin_languages, ngram_frequencies}
  end

  def subset(ngram_frequencies, languages) do
    new_ngram_frequencies =
      for {ngram, frequencies} <- ngram_frequencies, into: %{} do
        {_, frequencies} =
          @builtin_languages
          |> Enum.zip(frequencies)
          |> Enum.filter(fn {language, _} -> language in languages end)
          |> Enum.unzip()

        {ngram, frequencies}
      end

    {Enum.sort(languages), new_ngram_frequencies}
  end

  def clean(text) do
    {latin_count, non_latin_count} =
      List.foldl(text, {0, 0}, fn
        char, {latin_count, non_latin_count} when char in ?A..?z ->
          {latin_count + 1, non_latin_count}

        char, {latin_count, non_latin_count} when char > 0x0300 ->
          if unicode_block(char) != :latin_extended_additional do
            {latin_count, non_latin_count + 1}
          else
            {latin_count, non_latin_count}
          end

        _, counts ->
          counts
      end)

    if latin_count * 2 < non_latin_count do
      Enum.reject(text, &(&1 in ?A..?z))
    else
      text
    end
  end

  # Normalizer for Vietnamese.
  # Normalize Alphabet + Diacritical Mark (\u03xx) into \u1Exx.

  def normalize([alphabet, dmark | tail])
      when alphabet in @to_normalize_chars and dmark in @dmark_class do
    alphabet_index = Enum.find_index(@to_normalize_chars, fn char -> char == alphabet end)
    dmark_index = Enum.find_index(@dmark_class, fn char -> char == dmark end)

    [
      @normalized_vi_chars
      |> Enum.at(dmark_index)
      |> Enum.at(alphabet_index)
      | normalize(tail)
    ]
  end

  def normalize([char | tail]) do
    char =
      case unicode_block(char) do
        :basic_latin when char not in ?a..?z and char not in ?A..?Z ->
          ?\s

        :latin_1_supplement when char in @latin1_excluded ->
          ?\s

        :general_punctuation ->
          ?\s

        :latin_extended_additional when char >= 0x1EA0 ->
          0x1EC3

        :hiragana ->
          0x3042

        :katakana ->
          0x30A2

        :bopomofo ->
          0x3105

        :bopomofo_extended ->
          0x3105

        :cjk_unified_ideographs ->
          Map.get(@cjk_map, char, char)

        :hangul_syllables ->
          0xAC00

        _ ->
          case char do
            # Normalization for Romanian

            0x0219 ->
              # Small "S" with comma below -> with cedilla
              0x015F

            0x021B ->
              # Small "T" with comma below -> with cedilla
              0x0163

            0x06CC ->
              # Farsi yeh -> Arabic yeh
              0x064A

            _ ->
              char
          end
      end

    [char | normalize(tail)]
  end

  def normalize([]), do: []

  def extract_ngrams(text, ngram_frequencies) when is_list(text) do
    text
    |> extract_ngrams(ngram_frequencies, ' ', false)
    |> List.flatten()
  end

  def extract_ngrams([?\s | tail], ngram_frequencies, [?\s | _], _) do
    extract_ngrams(tail, ngram_frequencies, ' ', false)
  end

  def extract_ngrams([char | tail], ngram_frequencies, [?\s | _], _) do
    grams = [char, ?\s]

    [
      extract_features(grams, ngram_frequencies)
      | extract_ngrams(tail, ngram_frequencies, grams, false)
    ]
  end

  def extract_ngrams([char | tail], ngram_frequencies, grams, capitalword) do
    grams =
      if length(grams) >= @n_gram do
        [char | Enum.drop(grams, -1)]
      else
        [char | grams]
      end

    if is_capital?(grams, capitalword) do
      extract_ngrams(tail, ngram_frequencies, grams, true)
    else
      [
        extract_features(grams, ngram_frequencies)
        | extract_ngrams(tail, ngram_frequencies, grams, false)
      ]
    end
  end

  def extract_ngrams([], _, _, _), do: []

  def extract_features(grams, ngram_frequencies) do
    for n <- 1..length(grams) do
      grams
      |> Enum.slice(0, n)
      |> Enum.reverse()
      |> to_string
    end
    |> Enum.filter(&Map.has_key?(ngram_frequencies, &1))
  end

  def calculate_probabilities([], _, _), do: []

  def calculate_probabilities(ngrams, languages, ngram_frequencies) do
    :rand.seed(:exrop, :erlang.timestamp())

    initial_probabilities = fill(1 / length(languages), length(languages))

    1..@n_trial
    |> Enum.reduce(fill(0, length(languages)), fn _, probabilities ->
      weight = (@alpha_default + :rand.uniform() * @alpha_width) / @base_frequency

      Enum.reduce_while(0..@iteration_limit, initial_probabilities, fn i, probabilities ->
        ngram = Enum.at(ngrams, :rand.uniform(length(ngrams)) - 1)

        probabilities =
          ngram_frequencies
          |> Map.get(ngram)
          |> Nx.add(weight)
          |> Nx.multiply(probabilities)

        if rem(i, 5) == 0 do
          normalized_probabilities = Nx.divide(probabilities, Nx.sum(probabilities))

          max_probability = Nx.reduce_max(normalized_probabilities)

          if Nx.to_scalar(max_probability) > @convolution_threshold do
            {:halt, normalized_probabilities}
          else
            {:cont, normalized_probabilities}
          end
        else
          {:cont, probabilities}
        end
      end)
      |> Nx.add(probabilities)
    end)
    |> Nx.divide(@n_trial)
  end

  def fill(value, len) do
    Nx.tile(Nx.tensor([value], type: {:f, 32}), [len])
  end

  def calculate_probabilities_x(ngrams, languages, ngram_frequencies) do
    frequencies =
      ngrams
      |> Enum.map(&Map.get(ngram_frequencies, &1))
      |> Nx.concatenate()
      |> Nx.reshape({:auto, length(languages)})

    zero = Nx.tile(Nx.tensor(0, type: {:f, 32}), [length(languages)])
    initial_probabilities = Nx.tile(Nx.tensor(1 / length(languages), type: {:f, 32}), [length(languages)])

    calculate_probabilities_n(zero, initial_probabilities, frequencies)
  end

  @defn_compiler EXLA
  defn calculate_probabilities_n(zero, initial_probabilities, frequencies) do
    while {x = 0, a = zero, c = initial_probabilities, d = frequencies}, x < @n_trial + 1 do
      weight = Nx.random_uniform({1}, @alpha_default, @alpha_default + @alpha_width) / @base_frequency

      {_, probabilities, _, _} =
        while {i = 1, b = c, z = d, w = weight}, i < @iteration_limit do
          {ngrams_count, _} = Nx.shape(z)

          probabilities =
            z[Nx.random_uniform({1}, 0, ngrams_count - 1)]
            |> Nx.add(w)
            |> Nx.multiply(b)

          if rem(i, 5) == 0 do
            normalized_probabilities = Nx.divide(probabilities, Nx.sum(probabilities))

            max_probability = Nx.reduce_max(normalized_probabilities)

            if max_probability > @convolution_threshold do
              {@iteration_limit, normalized_probabilities, z, w}
            else
              {i + 1, normalized_probabilities, z, w}
            end
          else
            {i + 1, probabilities, z, w}
          end
        end

      {x + 1, a + probabilities, c, d}
    end
    |> elem(1)
    |> Nx.divide(@n_trial)
  end

  def filter_probabilities(probabilities, languages) do
    languages
    |> Enum.zip(Nx.to_flat_list(probabilities))
    |> Enum.filter(fn {_, probability} -> probability > @probability_threshold end)
  end

  Enum.map(@blocks, fn {from, to, block} ->
    def unicode_block(char) when char in unquote(from)..unquote(to) do
      unquote(block)
    end
  end)

  def unicode_block(char) when is_integer(char), do: nil

  def is_upcase?(char) when is_integer(char) do
    <<char::utf8>> != String.downcase(<<char::utf8>>)
  end

  def is_capital?([char, last_char | _], capitalword) do
    cond do
      not is_upcase?(char) ->
        false

      not is_upcase?(last_char) ->
        capitalword

      true ->
        false
    end
  end
end
