defmodule Twirp.Test.Envelope do
  @moduledoc false

  use Protobuf,
    full_name: "twirp.test.Envelope",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :msg, 1, type: :string
  field :sub, 2, type: Twirp.Test.Req
end

defmodule Twirp.Test.Req do
  @moduledoc false

  use Protobuf, full_name: "twirp.test.Req", protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  field :msg, 1, type: :string
end

defmodule Twirp.Test.Resp do
  @moduledoc false

  use Protobuf, full_name: "twirp.test.Resp", protoc_gen_elixir_version: "0.17.0", syntax: :proto3

  field :msg, 1, type: :string
end

defmodule Twirp.Test.BatchReq do
  @moduledoc false

  use Protobuf,
    full_name: "twirp.test.BatchReq",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :requests, 1, repeated: true, type: Twirp.Test.Req
end

defmodule Twirp.Test.BatchResp do
  @moduledoc false

  use Protobuf,
    full_name: "twirp.test.BatchResp",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :responses, 1, repeated: true, type: Twirp.Test.Resp
end
