-module(controller).
-import(myserver,[add/2, get_db/0]).

% Export all functions------------------------------------------------
-export([generate_name/0, generate_permission/0, gen_emp/1, gen_client/0,
	loop/1, show/0]).

% Function main-------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

% create 1 employee who is described by a process---------------------
gen_client() ->
	receive
		{_, {ok, Name}} ->
			io:format("server added ~p to database~n~n", [Name]),
			gen_client();
		{_, {already_exsist, Name}} ->
			io:format("in database ~p already existed~n~n", [Name]),		
			gen_client();
		terminate ->
			ok;
		_ ->
			{ok, error}
	end.

% create n employees who is described by a process---------------------
loop(0) ->
	ok;

loop(N) ->
	Name = generate_name(),
	Id = spawn(?MODULE, gen_client, []),
	io:format("~p.Client created ~p for ~p~n", [N, Id, Name]),
	server:add(Name, Id),
	receive
		{From, Message} ->
			Id ! {From, Message},
			timer:sleep(1000),
			loop(N - 1);
		terminate ->
			ok;
		_ ->
			{ok, error}	
	end.

% Function generator employees-----------------------------------------
gen_emp(N) ->
	spawn(?MODULE, loop, [N]),
	ok.

% Show in database-----------------------------------------------------
show() ->
	server:get_db(),
	receive
		{_, Message} ->
			io:format("Database = ~p ", [Message]),
			io:format("~n"),
			ok;
		terminate ->
			ok;
		_ ->
			{ok, error}
	end.
	

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

generate_permission() -> crypto:rand_uniform(1, 3).
