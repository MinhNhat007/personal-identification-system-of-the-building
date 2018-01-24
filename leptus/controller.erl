-module(controller).
-import(server,[add/2, get_db/0, verify/1, get_length/0]).

% Export all functions------------------------------------------------
-export([generate_name/0, generate_permission/0, gen_emp/1, gen_client/0,
	loop/1, show_emp/0, simulation/1, get_list_db/0, type_simulation/0]).

% Initialization------------------------------------------------------
-define(second, 1000).
-define(zone, 2).

% Function main-------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% create 1 employee who is described by a process---------------------
%% [{request_entry, }]
gen_client() ->
	receive
		{_, {added, {Name, Per}}} ->
			io:format("Server added ~p to database with permission ~p~n~n", [Name, Per]),
			gen_client();
		{_, {already_exsist, Name}} ->
			io:format("In database ~p already 
					existed~n~n", [Name]),		
			gen_client();


		{From, request_entry} ->
    		server:verify(self()),
			receive
      			{_, {admission, _}} ->
        			From ! {self(), admission};
      			{_, no_admission} ->
        			From ! {self(), no_admission};
				terminate ->
					ok
    		end,
			gen_client();	
		
		terminate ->
			ok
	end.

% create n employees who is described by a process---------------------
loop(0) ->
	ok;

loop(N) ->
	Name = generate_name(),
	Id = spawn(?MODULE, gen_client, []),% generate employee
	Per = generate_permission(),
	io:format("~p.System created ~p for ~p with permission ~p~n", [N, Id, Name, Per]),
	server:add(Name, Id, Per),
	receive
		{From, {added, Message}} ->
			Id ! {From, {added, Message}},
			loop(N - 1);
		terminate ->
			ok
	end.

% Function generator employees-----------------------------------------
gen_emp(N) ->
	loop(N).

% Show in database-----------------------------------------------------
show_emp() ->
	Message = get_list_db(),
	io:format("Database of employees = ~p ~n", [Message]),
	ok.

% get list database-----------------------------------------------------
get_list_db() ->
	server:get_db(),
	Result =
		receive
			{_, {get_db, Message}} ->
				Message;
			{_, _} ->
				[];
			terminate ->
				ok
		end,
	Result.


% Type simulation-----------------------------------------------------
type_simulation() ->
	Type = crypto:rand_uniform(1, 3),
	Res = 
		case Type of
			1 -> stranger;
			2 -> employee	
		end,
	Res.
% Simulation----------------------------------------------------------
simulation(stranger) ->
	ID = spawn(fun() -> do_something end),
	Name = generate_name(),
	{ID, Name};

simulation(employee) ->
	DB = get_list_db(),
	Size = length(DB),
	Number_employee = 	if 
						Size > 0 -> crypto:rand_uniform(1, Size);
						true -> 0
					end,
	{ID, {Name, _}} = lists:nth(Number_employee, DB),
	{ID, Name}.

% Function generation-------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
generate_name() -> 
	random_chars(6).
random_chars(L) -> 
	gen_rnd(L, get_consonant_list(), get_vowel_list(),[]).

get_vowel_list() -> 
	"aeiouy".
get_consonant_list() -> 
	"bcdfghjklmnopqrstvwxz".

gen_rnd(0,_,_, Res) -> Res;

gen_rnd(Length,	FirstChars, SecondChars,Res) ->
  MaxLength = length(FirstChars),
  M=lists:nth(crypto:rand_uniform(1, MaxLength), FirstChars),
  gen_rnd(Length-1,SecondChars,FirstChars, Res++[M]).

generate_permission() -> crypto:rand_uniform(1, ?zone+1).
