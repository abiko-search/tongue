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
    assert normalize('') == ''
    assert normalize('ABC') == 'ABC'
    assert normalize('\u0000') == ' '
    assert normalize('\u0009') == ' '
    assert normalize('\u0020') == ' '
    assert normalize('\u0030') == ' '
    assert normalize('\u0040') == ' '
    assert normalize('\u0041') == '\u0041'
    assert normalize('\u005A') == '\u005A'
    assert normalize('\u005B') == ' '
    assert normalize('\u0060') == ' '
    assert normalize('\u0061') == '\u0061'
    assert normalize('\u007A') == '\u007A'
    assert normalize('\u007B') == ' '
    assert normalize('\u007F') == ' '
    assert normalize('\u0080') == '\u0080'
    assert normalize('\u00A0') == ' '
    assert normalize('\u00A1') == '\u00A1'
  end

  test "normalize with CJK Kanji" do
    assert normalize('\u4E00') == '\u4E00'
    assert normalize('\u4E01') == '\u4E01'
    assert normalize('\u4E02') == '\u4E02'
    assert normalize('\u4E03') == '\u4E01'
    assert normalize('\u4E04') == '\u4E04'
    assert normalize('\u4E05') == '\u4E05'
    assert normalize('\u4E06') == '\u4E06'
    assert normalize('\u4E07') == '\u4E07'
    assert normalize('\u4E08') == '\u4E08'
    assert normalize('\u4E09') == '\u4E09'
    assert normalize('\u4E10') == '\u4E10'
    assert normalize('\u4E11') == '\u4E11'
    assert normalize('\u4E12') == '\u4E12'
    assert normalize('\u4E13') == '\u4E13'
    assert normalize('\u4E14') == '\u4E14'
    assert normalize('\u4E15') == '\u4E15'
    assert normalize('\u4E1E') == '\u4E1E'
    assert normalize('\u4E1F') == '\u4E1F'
    assert normalize('\u4E20') == '\u4E20'
    assert normalize('\u4E21') == '\u4E21'
    assert normalize('\u4E22') == '\u4E22'
    assert normalize('\u4E23') == '\u4E23'
    assert normalize('\u4E24') == '\u4E13'
    assert normalize('\u4E25') == '\u4E13'
    assert normalize('\u4E30') == '\u4E30'
  end

  test "normalize for Romanian" do
    assert normalize('\u015F') == '\u015F'
    assert normalize('\u0163') == '\u0163'
    assert normalize('\u0219') == '\u015F'
    assert normalize('\u021B') == '\u0163'
  end

  test "normalize Vietnamese" do
    assert normalize('\u00c0') == '\u00c0'
    assert normalize('\u0041\u0300') == '\u00C0'
    assert normalize('\u0045\u0300') == '\u00C8'
    assert normalize('\u0049\u0300') == '\u00CC'
    assert normalize('\u004F\u0300') == '\u00D2'
    assert normalize('\u0055\u0300') == '\u00D9'
    assert normalize('\u0059\u0300') == '\u1EF2'
    assert normalize('\u0061\u0300') == '\u00E0'
    assert normalize('\u0065\u0300') == '\u00E8'
    assert normalize('\u0069\u0300') == '\u00EC'
    assert normalize('\u006F\u0300') == '\u00F2'
    assert normalize('\u0075\u0300') == '\u00F9'
    assert normalize('\u0079\u0300') == '\u1EF3'
    assert normalize('\u00C2\u0300') == '\u1EA6'
    assert normalize('\u00CA\u0300') == '\u1EC0'
    assert normalize('\u00D4\u0300') == '\u1ED2'
    assert normalize('\u00E2\u0300') == '\u1EA7'
    assert normalize('\u00EA\u0300') == '\u1EC1'
    assert normalize('\u00F4\u0300') == '\u1ED3'
    assert normalize('\u0102\u0300') == '\u1EB0'
    assert normalize('\u0103\u0300') == '\u1EB1'
    assert normalize('\u01A0\u0300') == '\u1EDC'
    assert normalize('\u01A1\u0300') == '\u1EDD'
    assert normalize('\u01AF\u0300') == '\u1EEA'
    assert normalize('\u01B0\u0300') == '\u1EEB'

    assert normalize('\u0041\u0301') == '\u00C1'
    assert normalize('\u0045\u0301') == '\u00C9'
    assert normalize('\u0049\u0301') == '\u00CD'
    assert normalize('\u004F\u0301') == '\u00D3'
    assert normalize('\u0055\u0301') == '\u00DA'
    assert normalize('\u0059\u0301') == '\u00DD'
    assert normalize('\u0061\u0301') == '\u00E1'
    assert normalize('\u0065\u0301') == '\u00E9'
    assert normalize('\u0069\u0301') == '\u00ED'
    assert normalize('\u006F\u0301') == '\u00F3'
    assert normalize('\u0075\u0301') == '\u00FA'
    assert normalize('\u0079\u0301') == '\u00FD'
    assert normalize('\u00C2\u0301') == '\u1EA4'
    assert normalize('\u00CA\u0301') == '\u1EBE'
    assert normalize('\u00D4\u0301') == '\u1ED0'
    assert normalize('\u00E2\u0301') == '\u1EA5'
    assert normalize('\u00EA\u0301') == '\u1EBF'
    assert normalize('\u00F4\u0301') == '\u1ED1'
    assert normalize('\u0102\u0301') == '\u1EAE'
    assert normalize('\u0103\u0301') == '\u1EAF'
    assert normalize('\u01A0\u0301') == '\u1EDA'
    assert normalize('\u01A1\u0301') == '\u1EDB'
    assert normalize('\u01AF\u0301') == '\u1EE8'
    assert normalize('\u01B0\u0301') == '\u1EE9'

    assert normalize('\u0041\u0303') == '\u00C3'
    assert normalize('\u0045\u0303') == '\u1EBC'
    assert normalize('\u0049\u0303') == '\u0128'
    assert normalize('\u004F\u0303') == '\u00D5'
    assert normalize('\u0055\u0303') == '\u0168'
    assert normalize('\u0059\u0303') == '\u1EF8'
    assert normalize('\u0061\u0303') == '\u00E3'
    assert normalize('\u0065\u0303') == '\u1EBD'
    assert normalize('\u0069\u0303') == '\u0129'
    assert normalize('\u006F\u0303') == '\u00F5'
    assert normalize('\u0075\u0303') == '\u0169'
    assert normalize('\u0079\u0303') == '\u1EF9'
    assert normalize('\u00C2\u0303') == '\u1EAA'
    assert normalize('\u00CA\u0303') == '\u1EC4'
    assert normalize('\u00D4\u0303') == '\u1ED6'
    assert normalize('\u00E2\u0303') == '\u1EAB'
    assert normalize('\u00EA\u0303') == '\u1EC5'
    assert normalize('\u00F4\u0303') == '\u1ED7'
    assert normalize('\u0102\u0303') == '\u1EB4'
    assert normalize('\u0103\u0303') == '\u1EB5'
    assert normalize('\u01A0\u0303') == '\u1EE0'
    assert normalize('\u01A1\u0303') == '\u1EE1'
    assert normalize('\u01AF\u0303') == '\u1EEE'
    assert normalize('\u01B0\u0303') == '\u1EEF'

    assert normalize('\u0041\u0309') == '\u1EA2'
    assert normalize('\u0045\u0309') == '\u1EBA'
    assert normalize('\u0049\u0309') == '\u1EC8'
    assert normalize('\u004F\u0309') == '\u1ECE'
    assert normalize('\u0055\u0309') == '\u1EE6'
    assert normalize('\u0059\u0309') == '\u1EF6'
    assert normalize('\u0061\u0309') == '\u1EA3'
    assert normalize('\u0065\u0309') == '\u1EBB'
    assert normalize('\u0069\u0309') == '\u1EC9'
    assert normalize('\u006F\u0309') == '\u1ECF'
    assert normalize('\u0075\u0309') == '\u1EE7'
    assert normalize('\u0079\u0309') == '\u1EF7'
    assert normalize('\u00C2\u0309') == '\u1EA8'
    assert normalize('\u00CA\u0309') == '\u1EC2'
    assert normalize('\u00D4\u0309') == '\u1ED4'
    assert normalize('\u00E2\u0309') == '\u1EA9'
    assert normalize('\u00EA\u0309') == '\u1EC3'
    assert normalize('\u00F4\u0309') == '\u1ED5'
    assert normalize('\u0102\u0309') == '\u1EB2'
    assert normalize('\u0103\u0309') == '\u1EB3'
    assert normalize('\u01A0\u0309') == '\u1EDE'
    assert normalize('\u01A1\u0309') == '\u1EDF'
    assert normalize('\u01AF\u0309') == '\u1EEC'
    assert normalize('\u01B0\u0309') == '\u1EED'

    assert normalize('\u0041\u0323') == '\u1EA0'
    assert normalize('\u0045\u0323') == '\u1EB8'
    assert normalize('\u0049\u0323') == '\u1ECA'
    assert normalize('\u004F\u0323') == '\u1ECC'
    assert normalize('\u0055\u0323') == '\u1EE4'
    assert normalize('\u0059\u0323') == '\u1EF4'
    assert normalize('\u0061\u0323') == '\u1EA1'
    assert normalize('\u0065\u0323') == '\u1EB9'
    assert normalize('\u0069\u0323') == '\u1ECB'
    assert normalize('\u006F\u0323') == '\u1ECD'
    assert normalize('\u0075\u0323') == '\u1EE5'
    assert normalize('\u0079\u0323') == '\u1EF5'
    assert normalize('\u00C2\u0323') == '\u1EAC'
    assert normalize('\u00CA\u0323') == '\u1EC6'
    assert normalize('\u00D4\u0323') == '\u1ED8'
    assert normalize('\u00E2\u0323') == '\u1EAD'
    assert normalize('\u00EA\u0323') == '\u1EC7'
    assert normalize('\u00F4\u0323') == '\u1ED9'
    assert normalize('\u0102\u0323') == '\u1EB6'
    assert normalize('\u0103\u0323') == '\u1EB7'
    assert normalize('\u01A0\u0323') == '\u1EE2'
    assert normalize('\u01A1\u0323') == '\u1EE3'
    assert normalize('\u01AF\u0323') == '\u1EF0'
    assert normalize('\u01B0\u0323') == '\u1EF1'
  end

  test "extract ngrams" do
    ngram_frequencies = %{
      "A" => [],
      " A" => [],
      "A " => [],
      "B" => [],
      " B" => []
    }

    assert extract_ngrams('A B', ngram_frequencies) == ["A", " A", "A ", "B", " B"]
  end
end
