-module(server).
-behaviour(gen_server).

% Export all functions------------------------------------------------
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
	 terminate/2, code_change/3]).

-export([start/0, add/3, verify/1, delete/1, get_db/0, get_length/0]).

%% define-------------------------------------------------------------
-define(SERVER, ?MODULE).

%% function write from here-------------------------------------------

%% get number of employees--------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
get_length() ->
	gen_server:call(?MODULE, {get_length}).

%% add new employee---------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
add(Name, Id, Per) ->
	gen_server:call(?MODULE, 
			{add, {Name, Id, Per}}).

%% verify id function-------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
verify(Id) ->
	gen_server:call(?MODULE, {verify, Id}).

%% delete id function-------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
delete(Id) ->
	gen_server:call(?MODULE, {delete, Id}).

%% delete database----------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
get_db() ->
	gen_server:call(?MODULE, {get_db}).



%% handel call for server---------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------

% call server function get_length
handle_call({get_length}, _From, Library) ->
	Response = {get_length, length(dict:to_list(Library))},
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server function add
handle_call({add, {Name, Id, Per}}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->	
			NewLibrary = Library,
			{already_exsist, Name};
		false ->
			NewLibrary = dict:append(Id, {Name, Per}, Library),
			{added, {Name, Per}}	
	end,	
	gen_server:reply(_From, Response),
	{reply, Response, NewLibrary};

% call server function verify id
handle_call({verify, Id}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->
			{ok, Value} = dict:find(Id, Library),
			{Name, _} = hd(Value),
			{admission, Name};
		false ->
			no_admission
	end,
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server function delete
handle_call({delete, Id}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->
			{ok, Value} = dict:find(Id, Library),
			NewLibrary = dict:erase(Id, Library),
			{Name, _} = hd(Value),
			{deleted, Id, Name};
		false ->
			NewLibrary = Library,
			{no_found, Id}
	end,
	gen_server:reply(_From, Response),
	{reply, Response, NewLibrary};

% call server function get database
handle_call({get_db}, _From, Library) ->
	Response = {get_db, dict:to_list(Library)},
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server for case error
handle_call(_Message, _From, Library) ->
	{reply, error, Library}.

%% cast function------------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% start server-------------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
start() -> gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% init when start a server-------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
init([]) ->
	Library = dict:new(),
	{ok, Library}.


%% info function------------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%% terminate function-------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% code change function-----------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
        {ok, State}.
