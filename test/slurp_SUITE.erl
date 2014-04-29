-module(slurp_SUITE).
-compile(export_all).

-import(slurp, [slurp/1]).

-include_lib("common_test/include/ct.hrl").

-define(HTTP_URL, <<"http://echo.jsontest.com/rpt/slurp">>).
-define(RESPONSE, <<"{\"rpt\": \"slurp\"}\n">>).
-define(EXAMPLE, <<"example.file">>).
-define(CONTENT, <<"content\n">>).

all() ->
    [http_prefix,
     file_prefix,
     file_without_prefix,
     error_not_supported,
     error_bad_url].

http_prefix(_Config) ->
    {ok, ?RESPONSE} = slurp(?HTTP_URL).

file_prefix(Config) ->
    {ok, ?CONTENT} = slurp([<<"file://">>, get_path(Config)]).

file_without_prefix(Config) ->
    {ok, ?CONTENT} = slurp(get_path(Config)).

error_not_supported(_Config) ->
    {error, not_supported} = slurp(<<"weird://something">>).

error_bad_url(_Config) ->
    {error, _} = slurp(<<"http://some.weird.url">>).


get_path(Config) ->
    filename:join(?config(data_dir, Config), ?EXAMPLE).
