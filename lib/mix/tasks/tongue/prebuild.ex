defmodule Mix.Tasks.Tongue.Prebuild do
  use Mix.Task

  @shortdoc "Parse and prepare Erlang term files for Unicode blocks and langdetect data"
  @moduledoc false

  def run(_args) do
    build_unicode_blocks()
    build_messages()
    build_profiles()
  end

  def build_unicode_blocks do
    File.write!(
      "./priv/unicode_blocks.binary",
      "./data/ucd/Blocks.txt"
      |> File.stream!()
      |> Stream.map(fn line ->
        with [_, from, to, block] <-
               Regex.run(~r/([A-F0-9]{4})\.\.([A-F0-9]{4}); ([\w\s-]*)/, line) do
          {
            String.to_integer(from, 16),
            String.to_integer(to, 16),
            block
            |> String.trim()
            |> String.replace(~r/[-\s]/, "_")
            |> String.downcase()
            |> String.to_atom()
          }
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> :erlang.term_to_binary([:compressed])
    )
  end

  def build_messages do
    File.write!(
      "./priv/messages.binary",
      "./data/tongue/messages.properties"
      |> File.stream!()
      |> Stream.map(&String.split(&1, "="))
      |> Map.new(fn [key, value] ->
        {
          key,
          value
          |> String.trim()
          |> Macro.unescape_string()
          |> String.to_charlist()
        }
      end)
      |> :erlang.term_to_binary([:compressed])
    )
  end

  def build_profiles do
    files =
      "./data/profiles"
      |> File.ls!()
      |> Enum.reject(&String.starts_with?(&1, "."))
      |> Enum.map(fn filename ->
        Path.join("./data/profiles", filename)
        |> File.read!()
        |> Jason.decode!()
      end)
      |> Enum.sort_by(& &1["name"])

    languages = Enum.map(files, &String.to_atom(&1["name"]))

    default = List.duplicate(0, length(languages))

    ngrams_frequencies =
      files
      |> Enum.with_index()
      |> List.foldl(%{}, fn {profile, index}, ngrams_frequencies ->
        n_words = List.last(profile["n_words"])

        Enum.reduce(profile["freq"], ngrams_frequencies, fn {ngram, count}, ngrams_frequencies ->
          language_frequencies =
            ngrams_frequencies
            |> Map.get(ngram, default)
            |> List.replace_at(index, count / n_words)

          Map.put(ngrams_frequencies, ngram, language_frequencies)
        end)
      end)

    File.write!(
      "./priv/profiles.binary",
      %{
        languages: languages,
        ngrams_frequencies: ngrams_frequencies
      }
      |> :erlang.term_to_binary([:compressed])
    )
  end
end
