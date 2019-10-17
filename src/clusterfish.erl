-module(clusterfish).

-export([start/0]).

start() ->
    PrivDirs = find_priv_dirs(code:get_path()),
    SchemaFiles = find_schemas(PrivDirs),
    Config = cuttlefish_config(SchemaFiles),
    ok = symlink_schema_files(SchemaFiles),
    ok = application_controller:change_application_data([], Config).

find_priv_dirs(Paths) ->
    find_priv_dirs(Paths, []).

find_priv_dirs([], PrivDirs) ->
    PrivDirs;
find_priv_dirs([H|T], PrivDirs) ->
    Name = application_name_from_path(H),
    find_priv_dirs(T, [get_priv_dir(Name)|PrivDirs]).

find_schemas(PrivDirs) ->
    find_schemas(PrivDirs, []).

find_schemas([], Schemas) -> Schemas;
find_schemas([H|T], Schemas) ->
    DiscoveredSchemas = [filename:join([H, Schema]) || Schema <- filelib:wildcard("*.schema", H)],
    find_schemas(T, DiscoveredSchemas ++ Schemas).

application_name_from_path(Path) ->
    PathTokens = filename:split(Path),
    do_application_name_from_path(PathTokens).

do_application_name_from_path([Token, "ebin"]) ->
    discard_after_hyphen(Token);
do_application_name_from_path([Token]) ->
    discard_after_hyphen(Token);
do_application_name_from_path([_|T]) ->
    do_application_name_from_path(T);
do_application_name_from_path([]) ->
    "".

discard_after_hyphen("-"++_) ->
    [];
discard_after_hyphen([H|T]) ->
    [H|discard_after_hyphen(T)];
discard_after_hyphen([]) ->
    [].
    
get_priv_dir(Name) ->
    has_priv_dir(code:priv_dir(Name)).

has_priv_dir({error, _}) -> [];
has_priv_dir(Path) -> Path.

cuttlefish_config(SchemaFiles) ->
    Schema = cuttlefish_schema:files(SchemaFiles),
    Config = cuttlefish_generator:map(Schema, []),
    Config.

symlink_schema_files([]) -> ok;
symlink_schema_files([H|T]) ->
    file:make_symlink(H, filename:join([code:lib_dir(), filename:basename(H)])),
    symlink_schema_files(T).
