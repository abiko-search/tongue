# Tongue

[![Hex.pm](https://img.shields.io/hexpm/v/tongue.svg?maxAge=2592000)](https://hex.pm/packages/tongue)
[![Hex.pm](https://img.shields.io/hexpm/l/tongue.svg?maxAge=2592000)](https://hex.pm/packages/tongue)

Elixir port of Nakatani Shuyo's natural language detector

## Installation

Add `tongue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:tongue, "~> 1.0.1"}]
end
```

## Usage

Detect language and return a scored list of languages:

```elixir
iex> Tongue.detect("The octopus is a soft-bodied, eight-armed mollusc of the order Octopoda, with around 300 known species. Along with squids, cuttlefish and nautiloids, they are classed as cephalopods.")
[en: 0.9999986358008764]
```

Detect language within subset of supported languages:

```elixir
iex> subset = Tongue.select_languages(~w(ru en es fr)a)
iex> Tongue.detect("El microprocesador (o simplemente procesador) es el circuito integrado central más complejo de un sistema informático; a modo de ilustración, se le suele llamar por analogía el «cerebro» de un ordenador.", subset)
[es: 0.9999977345738683]
```

## Languages

**Tongue** supports 55 languages out of the box ([ISO 639-1 codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)):

    af, ar, bg, bn, ca, cs, cy, da, de, el, en, es, et, fa, fi, fr, gu, he,
    hi, hr, hu, id, it, ja, kn, ko, lt, lv, mk, ml, mr, ne, nl, no, pa, pl,
    pt, ro, ru, sk, sl, so, sq, sv, sw, ta, te, th, tl, tr, uk, ur, vi, zh-cn, zh-tw

## Derivation    

**Tongue** is a derivative work from Nakatani Shuyo's [language-detection](https://github.com/shuyo/language-detection) library

## License

[Apache 2.0] © [Danila Poyarkov]

[Apache 2.0]: LICENSE
[Danila Poyarkov]: http://dannote.net