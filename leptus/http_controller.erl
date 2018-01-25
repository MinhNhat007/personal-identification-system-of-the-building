-module(http_controller).
-compile({parse_transform, leptus_pt}).
% Import all functions------------------------------------------------
-import(controller, [gen_emp/1, get_list_db/0, simulation/0, type_simulation/0]).

% Export all functions------------------------------------------------
-export([init/3]).
-export([post/3]).
-export([get/3]).
-export([terminate/4]).
-export([cross_domains/3]).

% Function generation and initialization------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

init(_Route, _Req, State) ->
    {ok, State}.

cross_domains(_Route, _Req, State) ->
  {['_'], State}.


% Function main-------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% Post function with endpoint contains number of employee-------------
post("/1/:number_employee", Req, State) ->
	Status = ok,
	Number_employee =
		try
			list_to_integer(binary_to_list(leptus_req:param(Req, number_employee)))
		catch
			_:_ -> 0
		end,
	controller:gen_emp(Number_employee),
	Body = [{<<"status">>, <<"succeed">>}],
    {Status, {json, Body}, State}.

% Get function with endpoint to show databse from server--------------
get("/2", _Reg, State) ->
	Status = ok,
	List = controller:get_list_db(),
	Body = [{list_to_binary(pid_to_list(X)), list_to_binary(Y ++ ":" ++ atom_to_list(Z))} || {X, {Y, Z}} <- List],
    {Status, {json, Body}, State};

% Get function to make simulation--------------------------------------
get("/3", _Reg, State) ->
	Status = ok,
	Type = controller:type_simulation(),
	{ID, _} = controller:simulation(Type),
	ID ! {self(), request_entry},
	Message = receive
				{_, Information} ->
					Information;
				terminate ->
					ok
			after 1000 ->
				{no_admission, stranger}
			end,
	{_, Reason} = Message,
	Body = [{<<"status">>, list_to_binary(atom_to_list(Status))}, {<<"type">>, list_to_binary(atom_to_list(Type))}, {<<"id">>, list_to_binary(pid_to_list(ID))}, {<<"server">>, list_to_binary(atom_to_list(Reason))}],
	{Status, {json, Body}, State}.

%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
terminate(_Reason, _Route, _Req, _State) ->
    ok.
