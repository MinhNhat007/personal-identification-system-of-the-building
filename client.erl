-module(client).
-import(myserver,[add/2]).

% Export all functions------------------------------------------------
-export([generate_name/0, generate_id/0, start/1, loop/1, 
	gen_client/1]).

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
gen_client(Server) ->
	Name = generate_name(),
	Id = 1,

	%myserver:add(Name, Id),
%czemu nie dziala receive, kurczek
	%	{_} ->
	%		io:format("hehe1");
	%	{_, _} ->
	%		io:format("hehe2");
	%	{_, _, _} ->
	%		io:format("hehe3");
	%	{_, _, _, _} ->
	%		io:format("hehe4");
	%	{_, _, _, _, _} ->
	%		io:format("hehe5")
	%	terminate ->
	%		ok	
	%end.
	
loop(Server) ->
	Id = spawn(?MODULE, gen_client, [Server]).
	%loop().	

start(Server) ->
	loop(Server).
