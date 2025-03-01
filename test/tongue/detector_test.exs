defmodule Tongue.DetectorTest do
  use ExUnit.Case

  doctest Tongue.Detector

  import Tongue.Detector

  test "Unicode block" do
    assert unicode_block(0x0065) == :basic_latin
    assert unicode_block(0x007F) == :basic_latin
    assert unicode_block(0x0080) == :latin_1_supplement
    assert unicode_block(0x21FF) == :arrows
    assert unicode_block(0x2200) == :mathematical_operators
    assert unicode_block(0x2201) == :mathematical_operators
    assert unicode_block(0x22FF) == :mathematical_operators
    assert unicode_block(0x2300) == :miscellaneous_technical
  end

  test "normalize with Latin" do
    assert normalize(~c'') == ~c''
    assert normalize(~c'ABC') == ~c'ABC'
    assert normalize(~c'\u0000') == ~c' '
    assert normalize(~c'\u0009') == ~c' '
    assert normalize(~c'\u0020') == ~c' '
    assert normalize(~c'\u0030') == ~c' '
    assert normalize(~c'\u0040') == ~c' '
    assert normalize(~c'\u0041') == ~c'\u0041'
    assert normalize(~c'\u005A') == ~c'\u005A'
    assert normalize(~c'\u005B') == ~c' '
    assert normalize(~c'\u0060') == ~c' '
    assert normalize(~c'\u0061') == ~c'\u0061'
    assert normalize(~c'\u007A') == ~c'\u007A'
    assert normalize(~c'\u007B') == ~c' '
    assert normalize(~c'\u007F') == ~c' '
    assert normalize(~c'\u0080') == ~c'\u0080'
    assert normalize(~c'\u00A0') == ~c' '
    assert normalize(~c'\u00A1') == ~c'\u00A1'
  end

  test "normalize with CJK Kanji" do
    assert normalize(~c'\u4E00') == ~c'\u4E00'
    assert normalize(~c'\u4E01') == ~c'\u4E01'
    assert normalize(~c'\u4E02') == ~c'\u4E02'
    assert normalize(~c'\u4E03') == ~c'\u4E01'
    assert normalize(~c'\u4E04') == ~c'\u4E04'
    assert normalize(~c'\u4E05') == ~c'\u4E05'
    assert normalize(~c'\u4E06') == ~c'\u4E06'
    assert normalize(~c'\u4E07') == ~c'\u4E07'
    assert normalize(~c'\u4E08') == ~c'\u4E08'
    assert normalize(~c'\u4E09') == ~c'\u4E09'
    assert normalize(~c'\u4E10') == ~c'\u4E10'
    assert normalize(~c'\u4E11') == ~c'\u4E11'
    assert normalize(~c'\u4E12') == ~c'\u4E12'
    assert normalize(~c'\u4E13') == ~c'\u4E13'
    assert normalize(~c'\u4E14') == ~c'\u4E14'
    assert normalize(~c'\u4E15') == ~c'\u4E15'
    assert normalize(~c'\u4E1E') == ~c'\u4E1E'
    assert normalize(~c'\u4E1F') == ~c'\u4E1F'
    assert normalize(~c'\u4E20') == ~c'\u4E20'
    assert normalize(~c'\u4E21') == ~c'\u4E21'
    assert normalize(~c'\u4E22') == ~c'\u4E22'
    assert normalize(~c'\u4E23') == ~c'\u4E23'
    assert normalize(~c'\u4E24') == ~c'\u4E13'
    assert normalize(~c'\u4E25') == ~c'\u4E13'
    assert normalize(~c'\u4E30') == ~c'\u4E30'
  end

  test "normalize for Romanian" do
    assert normalize(~c'\u015F') == ~c'\u015F'
    assert normalize(~c'\u0163') == ~c'\u0163'
    assert normalize(~c'\u0219') == ~c'\u015F'
    assert normalize(~c'\u021B') == ~c'\u0163'
  end

  test "normalize Vietnamese" do
    assert normalize(~c'\u00c0') == ~c'\u00c0'
    assert normalize(~c'\u0041\u0300') == ~c'\u00C0'
    assert normalize(~c'\u0045\u0300') == ~c'\u00C8'
    assert normalize(~c'\u0049\u0300') == ~c'\u00CC'
    assert normalize(~c'\u004F\u0300') == ~c'\u00D2'
    assert normalize(~c'\u0055\u0300') == ~c'\u00D9'
    assert normalize(~c'\u0059\u0300') == ~c'\u1EF2'
    assert normalize(~c'\u0061\u0300') == ~c'\u00E0'
    assert normalize(~c'\u0065\u0300') == ~c'\u00E8'
    assert normalize(~c'\u0069\u0300') == ~c'\u00EC'
    assert normalize(~c'\u006F\u0300') == ~c'\u00F2'
    assert normalize(~c'\u0075\u0300') == ~c'\u00F9'
    assert normalize(~c'\u0079\u0300') == ~c'\u1EF3'
    assert normalize(~c'\u00C2\u0300') == ~c'\u1EA6'
    assert normalize(~c'\u00CA\u0300') == ~c'\u1EC0'
    assert normalize(~c'\u00D4\u0300') == ~c'\u1ED2'
    assert normalize(~c'\u00E2\u0300') == ~c'\u1EA7'
    assert normalize(~c'\u00EA\u0300') == ~c'\u1EC1'
    assert normalize(~c'\u00F4\u0300') == ~c'\u1ED3'
    assert normalize(~c'\u0102\u0300') == ~c'\u1EB0'
    assert normalize(~c'\u0103\u0300') == ~c'\u1EB1'
    assert normalize(~c'\u01A0\u0300') == ~c'\u1EDC'
    assert normalize(~c'\u01A1\u0300') == ~c'\u1EDD'
    assert normalize(~c'\u01AF\u0300') == ~c'\u1EEA'
    assert normalize(~c'\u01B0\u0300') == ~c'\u1EEB'

    assert normalize(~c'\u0041\u0301') == ~c'\u00C1'
    assert normalize(~c'\u0045\u0301') == ~c'\u00C9'
    assert normalize(~c'\u0049\u0301') == ~c'\u00CD'
    assert normalize(~c'\u004F\u0301') == ~c'\u00D3'
    assert normalize(~c'\u0055\u0301') == ~c'\u00DA'
    assert normalize(~c'\u0059\u0301') == ~c'\u00DD'
    assert normalize(~c'\u0061\u0301') == ~c'\u00E1'
    assert normalize(~c'\u0065\u0301') == ~c'\u00E9'
    assert normalize(~c'\u0069\u0301') == ~c'\u00ED'
    assert normalize(~c'\u006F\u0301') == ~c'\u00F3'
    assert normalize(~c'\u0075\u0301') == ~c'\u00FA'
    assert normalize(~c'\u0079\u0301') == ~c'\u00FD'
    assert normalize(~c'\u00C2\u0301') == ~c'\u1EA4'
    assert normalize(~c'\u00CA\u0301') == ~c'\u1EBE'
    assert normalize(~c'\u00D4\u0301') == ~c'\u1ED0'
    assert normalize(~c'\u00E2\u0301') == ~c'\u1EA5'
    assert normalize(~c'\u00EA\u0301') == ~c'\u1EBF'
    assert normalize(~c'\u00F4\u0301') == ~c'\u1ED1'
    assert normalize(~c'\u0102\u0301') == ~c'\u1EAE'
    assert normalize(~c'\u0103\u0301') == ~c'\u1EAF'
    assert normalize(~c'\u01A0\u0301') == ~c'\u1EDA'
    assert normalize(~c'\u01A1\u0301') == ~c'\u1EDB'
    assert normalize(~c'\u01AF\u0301') == ~c'\u1EE8'
    assert normalize(~c'\u01B0\u0301') == ~c'\u1EE9'

    assert normalize(~c'\u0041\u0303') == ~c'\u00C3'
    assert normalize(~c'\u0045\u0303') == ~c'\u1EBC'
    assert normalize(~c'\u0049\u0303') == ~c'\u0128'
    assert normalize(~c'\u004F\u0303') == ~c'\u00D5'
    assert normalize(~c'\u0055\u0303') == ~c'\u0168'
    assert normalize(~c'\u0059\u0303') == ~c'\u1EF8'
    assert normalize(~c'\u0061\u0303') == ~c'\u00E3'
    assert normalize(~c'\u0065\u0303') == ~c'\u1EBD'
    assert normalize(~c'\u0069\u0303') == ~c'\u0129'
    assert normalize(~c'\u006F\u0303') == ~c'\u00F5'
    assert normalize(~c'\u0075\u0303') == ~c'\u0169'
    assert normalize(~c'\u0079\u0303') == ~c'\u1EF9'
    assert normalize(~c'\u00C2\u0303') == ~c'\u1EAA'
    assert normalize(~c'\u00CA\u0303') == ~c'\u1EC4'
    assert normalize(~c'\u00D4\u0303') == ~c'\u1ED6'
    assert normalize(~c'\u00E2\u0303') == ~c'\u1EAB'
    assert normalize(~c'\u00EA\u0303') == ~c'\u1EC5'
    assert normalize(~c'\u00F4\u0303') == ~c'\u1ED7'
    assert normalize(~c'\u0102\u0303') == ~c'\u1EB4'
    assert normalize(~c'\u0103\u0303') == ~c'\u1EB5'
    assert normalize(~c'\u01A0\u0303') == ~c'\u1EE0'
    assert normalize(~c'\u01A1\u0303') == ~c'\u1EE1'
    assert normalize(~c'\u01AF\u0303') == ~c'\u1EEE'
    assert normalize(~c'\u01B0\u0303') == ~c'\u1EEF'

    assert normalize(~c'\u0041\u0309') == ~c'\u1EA2'
    assert normalize(~c'\u0045\u0309') == ~c'\u1EBA'
    assert normalize(~c'\u0049\u0309') == ~c'\u1EC8'
    assert normalize(~c'\u004F\u0309') == ~c'\u1ECE'
    assert normalize(~c'\u0055\u0309') == ~c'\u1EE6'
    assert normalize(~c'\u0059\u0309') == ~c'\u1EF6'
    assert normalize(~c'\u0061\u0309') == ~c'\u1EA3'
    assert normalize(~c'\u0065\u0309') == ~c'\u1EBB'
    assert normalize(~c'\u0069\u0309') == ~c'\u1EC9'
    assert normalize(~c'\u006F\u0309') == ~c'\u1ECF'
    assert normalize(~c'\u0075\u0309') == ~c'\u1EE7'
    assert normalize(~c'\u0079\u0309') == ~c'\u1EF7'
    assert normalize(~c'\u00C2\u0309') == ~c'\u1EA8'
    assert normalize(~c'\u00CA\u0309') == ~c'\u1EC2'
    assert normalize(~c'\u00D4\u0309') == ~c'\u1ED4'
    assert normalize(~c'\u00E2\u0309') == ~c'\u1EA9'
    assert normalize(~c'\u00EA\u0309') == ~c'\u1EC3'
    assert normalize(~c'\u00F4\u0309') == ~c'\u1ED5'
    assert normalize(~c'\u0102\u0309') == ~c'\u1EB2'
    assert normalize(~c'\u0103\u0309') == ~c'\u1EB3'
    assert normalize(~c'\u01A0\u0309') == ~c'\u1EDE'
    assert normalize(~c'\u01A1\u0309') == ~c'\u1EDF'
    assert normalize(~c'\u01AF\u0309') == ~c'\u1EEC'
    assert normalize(~c'\u01B0\u0309') == ~c'\u1EED'

    assert normalize(~c'\u0041\u0323') == ~c'\u1EA0'
    assert normalize(~c'\u0045\u0323') == ~c'\u1EB8'
    assert normalize(~c'\u0049\u0323') == ~c'\u1ECA'
    assert normalize(~c'\u004F\u0323') == ~c'\u1ECC'
    assert normalize(~c'\u0055\u0323') == ~c'\u1EE4'
    assert normalize(~c'\u0059\u0323') == ~c'\u1EF4'
    assert normalize(~c'\u0061\u0323') == ~c'\u1EA1'
    assert normalize(~c'\u0065\u0323') == ~c'\u1EB9'
    assert normalize(~c'\u0069\u0323') == ~c'\u1ECB'
    assert normalize(~c'\u006F\u0323') == ~c'\u1ECD'
    assert normalize(~c'\u0075\u0323') == ~c'\u1EE5'
    assert normalize(~c'\u0079\u0323') == ~c'\u1EF5'
    assert normalize(~c'\u00C2\u0323') == ~c'\u1EAC'
    assert normalize(~c'\u00CA\u0323') == ~c'\u1EC6'
    assert normalize(~c'\u00D4\u0323') == ~c'\u1ED8'
    assert normalize(~c'\u00E2\u0323') == ~c'\u1EAD'
    assert normalize(~c'\u00EA\u0323') == ~c'\u1EC7'
    assert normalize(~c'\u00F4\u0323') == ~c'\u1ED9'
    assert normalize(~c'\u0102\u0323') == ~c'\u1EB6'
    assert normalize(~c'\u0103\u0323') == ~c'\u1EB7'
    assert normalize(~c'\u01A0\u0323') == ~c'\u1EE2'
    assert normalize(~c'\u01A1\u0323') == ~c'\u1EE3'
    assert normalize(~c'\u01AF\u0323') == ~c'\u1EF0'
    assert normalize(~c'\u01B0\u0323') == ~c'\u1EF1'
  end

  test "extract ngrams" do
    ngram_frequencies = %{
      "A" => [],
      " A" => [],
      "A " => [],
      "B" => [],
      " B" => []
    }

    assert extract_ngrams(~c'A B', ngram_frequencies) == ["A", " A", "A ", "B", " B"]
  end
end
