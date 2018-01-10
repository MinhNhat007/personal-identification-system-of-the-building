-module(myserver).
-behaviour(gen_server).

% Export all functions------------------------------------------------
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
	 terminate/2, code_change/3]).

-export([start/0, add/2, verify/1, delete/1]).

%% define-------------------------------------------------------------
-define(SERVER, ?MODULE).
-record(employee, {name, id}).

%% function write from here-------------------------------------------
%% add new employee---------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
add(Name, Id) ->
	gen_server:call(?MODULE, 
			{add, #employee{name=Name, id = Id}}).

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


%% handel call for server---------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------

% call server function add
handle_call({add, #employee{name=Name, id=Id}}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->	
			NewLibrary = Library,
			{already_exsist, Name};
		false ->
			NewLibrary = dict:append(Id, Name, Library),
			{ok, added}	
	end,	
	{reply, Response, NewLibrary};

% call server function verify id
handle_call({verify, Id}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->
			{ok, Value} = dict:find(Id, Library),
			{admission, hd(Value)};
		false ->
			no_admission
	end,
	{reply, Response, Library};

% call server function delete
handle_call({delete, Id}, _From, Library) ->
	Response = case dict:is_key(Id, Library) of
		true ->
			{ok, Name} = dict:find(Id, Library),
			NewLibrary = dict:erase(Id, Library),
			{deleted, Id, hd(Name)};
		false ->
			NewLibrary = Library,
			{no_found, Id}
	end,
	{reply, Response, NewLibrary}.

% call server for case error
handle_call(_Message, _From, Library) ->
	{reply, error, Library}.

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

%% cast function------------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

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
