-module(client).
-import(myserver,[add/2]).

% Export all functions------------------------------------------------
-export([generate_name/0, start/2, gen_client/2]).

% Function generation-------------------------------------------------
generate_name() -> 
	random_chars(6).
random_chars(L) -> 
	gen_rnd(L, get_consonant_list(), get_vowel_list(),[]).

get_vowel_list() -> 
	"aeiouy".
get_consonant_list() -> 
	"bcdfghjklmnpqrstvwxz".

gen_rnd(0,_,_, Res) -> Res;

gen_rnd(Length,	FirstChars, SecondChars,Res) ->
  MaxLength = length(FirstChars),
  M=lists:nth(crypto:rand_uniform(1, MaxLength), FirstChars),
  gen_rnd(Length-1,SecondChars,FirstChars, Res++[M]).

%%----------------------------------------
generatePerm(PermList) ->
	Length = length(PermList),
	No = crypto:rand_uniform(0, Length),
	if No==0 -> [];
	   true -> [lists:nth(crypto:rand_uniform(1,Length), PermList) ||
				  _ <- lists:seq(1, No)]
	end.

%% generate_id() -> crypto:rand_uniform(1, 1000).

% Function main-------------------------------------------------------
gen_client(Shell,PermList) ->
	Name = generate_name(),
	Perms = generatePerm(PermList),
	Pid = spawn_link(?MODULE,loop,[20]),
	myserver:add(Name, Pid, Perms),
	io:format("client create ~p for ~p~n", [Pid, Name]),
	receive
		{_, {ok, Name}} ->
			io:format("added ~p to database~n", [Name]),
			gen_client(Shell,PermList);
		{_, {already_exsist, Name}} ->
			io:format("~p already exist in database~n", [Name]),
			gen_client(Shell, PermList);
		terminate ->
			ok;
		_ ->
			{ok, error}
	after
		6000 ->
			ok	
	end.

loop(X) -> 
	receive
		terminate -> {ok,self()}
	after X*1000 ->
		{ok, self()}
	end.
		

start(Shell,PermList) ->
	spawn(?MODULE, gen_client, [Shell,PermList]),
	ok.
