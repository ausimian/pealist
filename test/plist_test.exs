defmodule PlistTest do
  use ExUnit.Case
  doctest Pealist

  # to update the binary plist after updating the XML one, run:
  # plistutil -i test/fixtures/xml.plist -o test/fixtures/binary.plist
  test "basic parsing (binary)" do
    plist = parse_fixture("binary.plist")
    assert_values(plist)
  end

  test "basic parsing (xml)" do
    plist = parse_fixture("xml.plist")
    assert_values(plist)
  end

  test "roundtrip (xml)" do
    original_xml =
      [File.cwd!(), "test", "fixtures", "xml.plist"]
      |> Path.join()
      |> File.read!()

    plist = Pealist.decode(original_xml)
    encoded_xml = Pealist.encode(plist)

    assert encoded_xml == original_xml
  end

  defp assert_values(decoded_plist) do
    assert Map.get(decoded_plist, "String") == "foobar"
    assert Map.get(decoded_plist, "SingleSpace") == " "
    assert Map.get(decoded_plist, "DoubleSpacedString") == "  foo  bar  "
    assert Map.get(decoded_plist, "Number") == 1234
    assert Map.get(decoded_plist, "Float") == 1234.1234
    assert Map.get(decoded_plist, "Array") == ["A", "B", "C", "", " "]
    assert Map.get(decoded_plist, "Date") == ~U[2015-11-17T14:00:59Z]
    assert Map.get(decoded_plist, "True") == true
    assert Map.get(decoded_plist, "False") == false
    assert Map.get(decoded_plist, "Base64") == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10>>
    assert Map.get(decoded_plist, "EntityEncoded") == "Foo & Bar"
    assert Map.get(decoded_plist, "UnicσdeKey") == "foobar"
    assert Map.get(decoded_plist, "UnicodeValue") == "© 2008 – 2016"
    assert Map.get(decoded_plist, "SomeUID")["CF$UID"] == 40
    assert Map.get(decoded_plist, "") == ""
  end

  defp parse_fixture(filename) do
    [File.cwd!(), "test", "fixtures", filename]
    |> Path.join()
    |> File.read!()
    |> Pealist.decode()
  end
end
