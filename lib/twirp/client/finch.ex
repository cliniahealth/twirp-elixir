defmodule Twirp.Client.Finch do
  @moduledoc false
  alias Twirp.Client.AdapterError

  require Logger

  def start_link(opts) do
    if Code.ensure_loaded?(Finch) do
      opts = Keyword.new(opts)
      Finch.start_link(opts)
    else
      raise AdapterError, :finch
    end
  end

  def request(client, ctx, path, payload) do
    # Finch validates request opts strictly (>= 0.16) and has no per-request
    # connect timeout — that's configured on the pool at start_link. So we only
    # pass the checkout (pool) and receive timeouts here.
    opts = [
      pool_timeout: ctx[:connect_deadline] || 1_000,
      receive_timeout: ctx.deadline
    ]

    request = Finch.build(:post, path, ctx.headers, payload)
    Finch.request(request, client, opts)
  end
end
