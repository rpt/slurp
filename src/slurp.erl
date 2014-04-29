-module(slurp).

-export([slurp/1]).

-type prefix() :: file | http.
-type result() :: {ok, binary()} | {error, term()}.

-spec slurp(iodata()) -> result().
slurp(Something) when is_binary(Something) ->
    case prefix(Something) of
        {file, Path} ->
            slurp_file(Path);
        {http, URL} ->
            slurp_http(URL);
        nothing ->
            case filelib:is_file(Something) of
                true ->
                    slurp_file(Something);
                false ->
                    {error, not_supported}
            end
    end;
slurp(Something) ->
    slurp(iolist_to_binary(Something)).

-spec prefix(binary()) -> {prefix(), binary()}.
prefix(<<"file://", Path/binary>>) ->
    {file, Path};
prefix(<<"http://", _/binary>> = URL) ->
    {http, URL};
prefix(_) ->
    nothing.

-spec slurp_file(binary()) -> result().
slurp_file(Path) ->
    file:read_file(Path).

-spec slurp_http(binary()) -> result().
slurp_http(URL) ->
    ok = inets:start(temporary),
    Result = httpc:request(binary_to_list(URL)),
    ok = inets:stop(),
    case Result of
        {ok, {_, _, Body}} ->
            {ok, list_to_binary(Body)};
        {error, _} = Error ->
            Error
    end.
