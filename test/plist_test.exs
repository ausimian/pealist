defmodule PlistTest do
  use ExUnit.Case
  doctest Pealist

  test "basic parsing (binary)" do
    plist = parse_fixture("binary.plist")

    assert Map.get(plist, "String") == "foobar"
    assert Map.get(plist, "Number") == 1234
    assert Map.get(plist, "Array") == ["A", "B", "C"]
    assert Map.get(plist, "Date") == ~U[2015-11-17T14:00:59Z]
    assert Map.get(plist, "True") == true
    assert Map.get(plist, "SomeUID")["CF$UID"] == 40
    assert Map.get(plist, "") == ""
  end

  test "basic parsing (xml)" do
    plist = parse_fixture("xml.plist")

    assert Map.get(plist, "String") == "foobar"
    assert Map.get(plist, "Number") == 1234
    assert Map.get(plist, "Float") == 1234.1234
    assert Map.get(plist, "Array") == ["A", "B", "C"]
    assert Map.get(plist, "Date") == ~U[2015-11-17T14:00:59Z]
    assert Map.get(plist, "True") == true
    assert Map.get(plist, "False") == false
    assert Map.get(plist, "Base64") == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10>>
    assert Map.get(plist, "EntityEncoded") == "Foo & Bar"
    assert Map.get(plist, "UnicσdeKey") == "foobar"
    assert Map.get(plist, "UnicodeValue") == "© 2008 – 2016"
    assert Map.get(plist, "SomeUID")["CF$UID"] == 40
    assert Map.get(plist, "") == ""
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

  defp parse_fixture(filename) do
    [File.cwd!(), "test", "fixtures", filename]
    |> Path.join()
    |> File.read!()
    |> Pealist.decode()
  end
end
