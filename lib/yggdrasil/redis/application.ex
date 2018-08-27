defmodule Yggdrasil.Redis.Application do
  @moduledoc """
  Module that defines Yggdrasil with Redis support.

  ![demo](https://raw.githubusercontent.com/gmtprime/yggdrasil_redis/master/images/demo.gif)

  ## Small example

  The following example uses Redis adapter to distribute messages:

  ```
  iex(1)> channel = %Yggdrasil.Channel{name: "some_channel", adapter: :redis}
  iex(2)> Yggdrasil.subscribe(channel)
  iex(3)> flush()
  {:Y_CONNECTED, %YggdrasilChannel{(...)}}
  ```

  and to publish a message for the subscribers:

  ```
  iex(4)> Yggdrasil.publish(channel, "message")
  iex(5)> flush()
  {:Y_EVENT, %Yggdrasil.Channel{(...)}, "message"}
  ```

  When the subscriber wants to stop receiving messages, then it can unsubscribe
  from the channel:

  ```
  iex(6)> Yggdrasil.unsubscribe(channel)
  iex(7)> flush()
  {:Y_DISCONNECTED, %Yggdrasil.Channel{(...)}}
  ```

  ## Redis adapter

  The Redis adapter has the following rules:
    * The `adapter` name is identified by the atom `:redis`.
    * The channel `name` must be a string.
    * The `transformer` must encode to a string. From the `transformer`s provided
    it defaults to `:default`, but `:json` can also be used.
    * Any `backend` can be used (by default is `:default`).

  The following is a valid channel for both publishers and subscribers:

  ```
  %Yggdrasil.Channel{
    name: "redis_channel_name",
    adapter: :redis,
    transformer: :json
  }
  ```

  It will expect valid JSONs from Redis and it will write valid JSONs in Redis.

  ## Redis configuration

  Uses the list of options for `Redix`, but the more relevant optuons are shown
  below:
    * `hostname` - Redis hostname (defaults to `"localhost"`).
    * `port` - Redis port (defaults to `6379`).
    * `password` - Redis password (defaults to `""`).

  The following shows a configuration with and without namespace:

  ```
  # Without namespace
  config :yggdrasil,
    redis: [hostname: "redis.zero"]

  # With namespace
  config :yggdrasil, RedisOne,
    redis: [
      hostname: "redis.one",
      port: 1234
    ]
  ```

  Also the options can be provided as OS environment variables. The available
  variables are:

    * `YGGDRASIL_REDIS_HOSTNAME` or `<NAMESPACE>_YGGDRASIL_REDIS_HOSTNAME`.
    * `YGGDRASIL_REDIS_PORT` or `<NAMESPACE>_YGGDRASIL_REDIS_PORT`.
    * `YGGDRASIL_REDIS_PASSWORD` or `<NAMESPACE>_YGGDRASIL_REDIS_PASSWORD`.
    * `YGGDRASIL_REDIS_DATABASE` or `<NAMESPACE>_YGGDRASIL_REDIS_DATABASE`.

  where `<NAMESPACE>` is the snakecase of the namespace chosen e.g. for the
  namespace `RedisTwo`, you would use `REDIS_TWO` as namespace in the OS
  environment variable.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Yggdrasil.Adapter.Redis, []}, [])
    ]

    opts = [strategy: :one_for_one, name: Yggdrasil.Redis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end