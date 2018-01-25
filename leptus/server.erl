-module(server).
-behaviour(gen_server).

% Export all functions------------------------------------------------
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
	 terminate/2, code_change/3]).

-export([start/0, add/3, verify/1, delete/1, get_db/0, get_length/0,
		start_clock/0, time_taken/1, get_time/0, check_time/1, 
		get_actual_time/0]).

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
add(Name, Id, TypePer) ->
	Per = case TypePer of
		1 -> normal;
		2 -> vip
	end,
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

%% get_actual_time----------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
get_actual_time() ->
	gen_server:call(?MODULE, {getTime}).



%% handel call for server---------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------

% call server function get_length
handle_call({getTime}, _From, Library) ->
	Time = get_time(),
	Response = {getTime, Time},
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server function get_length
handle_call({get_length}, _From, Library) ->
	Response = {get_length, length(maps:to_list(Library))},
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server function add
handle_call({add, {Name, Id, Per}}, _From, Library) ->
	Response = case maps:is_key(Id, Library) of
		true ->	
			NewLibrary = Library,
			{already_exsist, Name};
		false ->
			NewLibrary = maps:put(Id, {Name, Per}, Library),
			{added, {Name, Per}}	
	end,	
	gen_server:reply(_From, Response),
	{reply, Response, NewLibrary};

% call server function verify id
handle_call({verify, Id}, _From, Library) ->
	{Hour, _} = get_time(),
	InTime = check_time(Hour),
	Response = case maps:is_key(Id, Library) of
		true ->
			{_, Per} = maps:get(Id, Library),
			case InTime of
				true ->
					{admission, time_in};
				false ->
					case Per of
						vip ->	
							{admission, time_in};
						normal ->
							{no_admission, time_out}
					end
			end;
		_ ->
			{no_admission, stranger}
	end,
	gen_server:reply(_From, Response),
	{reply, Response, Library};

% call server function delete
handle_call({delete, Id}, _From, Library) ->
	Response = case maps:is_key(Id, Library) of
		true ->
			{{Name, _}, NewLibrary} = maps:take(Id, Library),
			{deleted, Id, Name};
		false ->
			NewLibrary = Library,
			{no_found, Id}
	end,
	gen_server:reply(_From, Response),
	{reply, Response, NewLibrary};

% call server function get database
handle_call({get_db}, _From, Library) ->
	Response = {get_db, maps:to_list(Library)},
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
start() -> 
	start_clock(),
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% init when start a server-------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
init([]) ->
	Library = maps:new(),
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

%% code handling time function----------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------

%% convert time to hour, minute---------------------------------------
check_time(Hour) when Hour < 8 -> false;
check_time(Hour) when Hour > 21 -> false;
check_time(_) -> true.

%% convert time to hour, minute---------------------------------------
change_time(Time) ->
	Second = Time / 1000000,
	Hour = round(Second) rem 24,
	Minute = 0,
	{Hour, Minute}.
	 
%% get time function--------------------------------------------------
get_time() ->
	Pid = whereis(myClock),
	Pid ! {self(), request_time},
	Time = receive
			{_, ActuallyTime} ->
				ActuallyTime;
			terminate ->
				ok	
		end,
	{Hour, Minute} = change_time(Time),
	{Hour, Minute}.

%% start clock function-----------------------------------------------
start_clock() ->
	Start = os:timestamp(),
	Pid = spawn(?MODULE, time_taken, [Start]),
	register(myClock, Pid).
%% calculate time from starting server--------------------------------
time_taken(StartTime) -> 
	receive
		{From, request_time} ->
			Time = timer:now_diff(os:timestamp(), StartTime),
			From ! {self(), Time},
			time_taken(StartTime);
		terminate ->
			ok
	end.
