-module(client).
-import(myserver,[add/2]).

% Export all functions------------------------------------------------
-export([generate_name/0, generate_id/0, start/1, gen_client/1]).

% Function generation-------------------------------------------------
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

generate_id() -> crypto:rand_uniform(1, 1000).

% Function main-------------------------------------------------------
gen_client(Shell) ->
	Name = generate_name(),
	myserver:add(Name, self()),
	io:format("client create ~p for ~p~n", [self(), Name]),
	receive
		{_, {ok, Name}} ->
			io:format("added ~p to database~n", [Name]),
			gen_client(Shell);
		{_, {already_exsist, Name}} ->
			io:format("~p already exist in database~n", [Name]),
			gen_client(Shell);
		terminate ->
			ok;
		_ ->
			{ok, error}
	after
		6000 ->
			ok	
	end.

start(Shell) ->
	spawn(?MODULE, gen_client, [Shell]),
	ok.
