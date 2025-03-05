defmodule Pealist.XML do
  require Record

  @moduledoc false

  Record.defrecordp(
    :element_node,
    :xmlElement,
    Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  )

  Record.defrecordp(
    :text_node,
    :xmlText,
    Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  )

  def decode(xml) do
    {doc, _} =
      xml
      |> :binary.bin_to_list()
      |> :xmerl_scan.string([{:comments, false}, {:space, :normalize}])

    root =
      doc
      |> element_node(:content)
      |> Enum.reject(&empty?/1)
      |> Enum.at(0)

    parse_value(root)
  end

  def encode(term) do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    #{encode_plist_data(term, 0)}</plist>
    """
  end

  defp parse_value(element_node() = element) do
    parse_value(element_node(element, :name), element_node(element, :content))
  end

  defp parse_value(:string, list) do
    do_parse_text_nodes(list, "")
  end

  defp parse_value(:date, nodes) do
    str = parse_value(:string, nodes)
    {:ok, dt, _} = DateTime.from_iso8601(str)
    dt
  end

  defp parse_value(:data, nodes) do
    {:ok, data} =
      parse_value(:string, nodes)
      |> Base.decode64(ignore: :whitespace)

    data
  end

  defp parse_value(true, []), do: true
  defp parse_value(false, []), do: false

  defp parse_value(:integer, nodes) do
    parse_value(:string, nodes) |> String.to_integer()
  end

  defp parse_value(:real, nodes) do
    {value, ""} = parse_value(:string, nodes) |> Float.parse()
    value
  end

  defp parse_value(:array, contents) do
    contents
    |> Enum.reject(&empty?/1)
    |> Enum.map(&parse_value/1)
  end

  defp parse_value(:dict, contents) do
    {keys, values} =
      contents
      |> Enum.reject(&empty?/1)
      |> Enum.split_with(fn element ->
        element_node(element, :name) == :key
      end)

    unless length(keys) == length(values), do: raise("Key/value pair mismatch")

    keys
    |> Enum.map(&element_text_value/1)
    |> Enum.zip(values)
    |> Enum.into(%{}, fn {key, element} ->
      {key, parse_value(element)}
    end)
  end

  defp element_text_value(element) do
    case element_node(element, :content) do
      [content_node] ->
        content_node
        |> text_node(:value)
        |> :unicode.characters_to_binary()

      [] ->
        ""
    end
  end

  defp do_parse_text_nodes([], result), do: result

  defp do_parse_text_nodes([node | list], result) do
    text = node |> text_node(:value) |> :unicode.characters_to_binary()
    do_parse_text_nodes(list, result <> text)
  end

  defp empty?({:xmlText, _, _, [], ~c" ", :text}), do: true
  defp empty?(_), do: false

  defp encode_plist_data(%NaiveDateTime{} = dt, level) do
    dt
    |> DateTime.from_naive!("Etc/UTC")
    |> encode_plist_data(level)
  end

  defp encode_plist_data(%DateTime{time_zone: "Etc/UTC"} = dt, level) do
    indent(["<date>", DateTime.to_iso8601(dt), "</date>\n"], level)
  end

  defp encode_plist_data(%DateTime{} = dt, _level) do
    raise "Unable to encode DateTime #{dt}, please use Etc/UTC timezone"
  end

  defp encode_plist_data(val, level) when is_map(val) do
    [
      indent("<dict>\n", level),
      val
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.map(fn {k, v} ->
        [
          indent(["<key>", xml_escape(k), "</key>\n"], level + 1),
          encode_plist_data(v, level + 1)
        ]
      end),
      indent("</dict>\n", level)
    ]
  end

  defp encode_plist_data(array, level) when is_list(array) do
    [
      indent("<array>\n", level),
      Enum.map(array, &encode_plist_data(&1, level + 1)),
      indent("</array>\n", level)
    ]
  end

  defp encode_plist_data(true, level), do: indent("<true/>\n", level)
  defp encode_plist_data(false, level), do: indent("<false/>\n", level)

  defp encode_plist_data(int, level) when is_integer(int) do
    indent(["<integer>", to_string(int), "</integer>\n"], level)
  end

  defp encode_plist_data(real, level) when is_float(real) do
    indent(["<real>", to_string(real), "</real>\n"], level)
  end

  defp encode_plist_data(str, level) when is_binary(str) do
    if String.printable?(str) do
      indent(["<string>", xml_escape(str), "</string>\n"], level)
    else
      indent(["<data>", Base.encode64(str), "</data>\n"], level)
    end
  end

  defp indent(str, level) when is_binary(str), do: indent([str], level)

  defp indent(io_list, level) when is_list(io_list) do
    [String.duplicate("  ", level) | io_list]
  end

  defp xml_escape(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace(~s("), "&quot;")
    |> String.replace("'", "&apos;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
