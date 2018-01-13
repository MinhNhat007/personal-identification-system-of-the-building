-module(controller).
-import(myserver,[add/2, get_db/0, verify/1, get_length/0]).

% Export all functions------------------------------------------------
-export([generate_name/0, generate_permission/0, gen_emp/1, gen_client/0,
	loop/1, show_emp/0, simulation/0, get_size/0, get_list_db/0]).

% Initialization------------------------------------------------------
-define(second, 1000).
-define(zone, 2).

% Function main-------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% create 1 employee who is described by a process---------------------
gen_client() ->
	receive
		{_, {added, {Name, Per}}} ->
			io:format("Server added ~p to database with permission ~p~n~n", [Name, Per]),
			gen_client();
		{_, {already_exsist, Name}} ->
			io:format("In database ~p already 
					existed~n~n", [Name]),		
			gen_client();
		{_, _} ->
			ok;
		terminate ->
			ok
	end.

% create n employees who is described by a process---------------------
loop(0) ->
	ok;

loop(N) ->
	Name = generate_name(),
	Id = spawn(?MODULE, gen_client, []),
	Per = generate_permission(),
	io:format("~p.System created ~p for ~p with permission ~p~n", [N, Id, Name, Per]),
	server:add(Name, Id, Per),
	receive
		{From, {added, Message}} ->
			Id ! {From, {added, Message}},
			timer:sleep(?second),
			loop(N - 1);
		{_, _} ->
			ok;
		terminate ->
			ok
	end.

% Function generator employees-----------------------------------------
gen_emp(N) ->
	spawn(?MODULE, loop, [N]),
	ok.

% Show in database-----------------------------------------------------
show_emp() ->
	Message = get_list_db(),
	io:format("Database of employees = ~p ~n", [Message]),
	ok.

% get list database-----------------------------------------------------
get_list_db() ->
	server:get_db(),
	N =
		receive
			{_, {get_db, Message}} ->
				Message;
			{_, _} ->
				[];
			terminate ->
				ok
		end,
	N.

% Simulation----------------------------------------------------------
simulation() ->
	Type = crypto:rand_uniform(1, 3),
	{Id, Name} = 
		case Type of
			1 ->
				Tmp_id = spawn(fun() -> do_something end),
				Tmp_name = generate_name(),
				io:format("System created ~p as a stranger with id ~p~n", [Tmp_name, Tmp_id]),
				{Tmp_id, Tmp_name};
			2 ->
				Tmp_size = get_size(),
				Tmp_employee = 
					if 
						Tmp_size > 0 ->
							crypto:rand_uniform(1, Tmp_size);
						true ->
							simulation()
					end,
				Tmp_list = get_list_db(),
				{Tmp_id, Data} = lists:nth(Tmp_employee, Tmp_list),
				{Tmp_name, _} = hd(Data),				
				io:format("System is checking admission for ~p~n", [Tmp_name]),
				{Tmp_id, Tmp_name}				
		end,
	server:verify(Id),
	receive
		{_, {admission, _}} ->
			io:format("Accept for ~p enter the building~n~n", [Name]),
			timer:sleep(?second),			
			simulation();
		{_, no_admission} ->
			io:format("There is no admission to ~p enter the building~n~n", [Name]),
			timer:sleep(?second),			
			simulation();
		{_,_} ->
			timer:sleep(?second),
			simulation();
		terminate ->
			ok						
	end.

% get size of database------------------------------------------------
get_size() ->
	server:get_db(),
	N = 
		receive
			{_, {get_db, Message}} ->
				length(Message);
			{_,_} ->
				0;
			terminate ->
				ok
		end,
	N.

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
