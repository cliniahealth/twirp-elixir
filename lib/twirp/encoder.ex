defmodule Twirp.Encoder do
  @moduledoc false

  # Encodes and Decodes messages based on the requests content-type header.
  # For json we delegate to Jason. for protobuf responses we use the input or
  # output types.

  @json "application/json"
  @proto "application/protobuf"

  @valid_types [@json, @proto]

  def valid_type?([]), do: false
  def valid_type?([type]) when type in @valid_types, do: true
  def valid_type?(type) when type in @valid_types, do: true
  def valid_type?(_), do: false

  def type(:proto), do: @proto
  def type(:json), do: @json

  def proto?(content_type), do: content_type == @proto

  def json?(content_type), do: content_type == @json

  def decode(bytes, input, @json <> _) when is_binary(bytes) do
    # protobuf-elixir's JSON decoder handles nested/repeated fields and enums,
    # and accepts both the proto field name and the camelCase json_name.
    Protobuf.JSON.decode(bytes, input)
  end

  def decode(data, input, @json <> _) do
    # Body already parsed into a map (e.g. Plug body_params). Round-trip it
    # through JSON so the protobuf decoder builds the nested struct correctly,
    # regardless of string/atom keys.
    with {:ok, json} <- Jason.encode(data) do
      Protobuf.JSON.decode(json, input)
    end
  rescue
    e ->
      {:error, e}
  end

  def decode(bytes, input, @proto <> _) do
    payload = input.decode(bytes)

    {:ok, payload}
  catch
    :error, reason ->
      {:error, reason}
  end

  def decode_json(bytes) do
    Jason.decode(bytes)
  end

  def encode(payload, _output, @json <> _) do
    if protobuf_message?(payload) do
      # Canonical protobuf-JSON (camelCase json_names, defaults omitted) — this
      # is what the Go (twitchtv/twirp) and Python (twirpy) JSON codecs speak.
      Protobuf.JSON.encode!(payload)
    else
      # Non-message payloads (e.g. a Twirp.Error, which implements Jason.Encoder).
      Jason.encode!(payload)
    end
  end

  def encode(payload, output, @proto <> _) do
    output.encode(payload)
  end

  defp protobuf_message?(%mod{}), do: function_exported?(mod, :__message_props__, 0)
  defp protobuf_message?(_), do: false
end
