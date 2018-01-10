%% @author Marcin_room
%% @doc @todo Add description to client.


-module(client).

%% ====================================================================
%% API functions
%% ====================================================================
-export([generate_name/0, generate_id/0]).


generate_name() 		-> random_chars(6).
random_chars(L)         -> gen_rnd(L, get_consonant_list(), get_vowel_list(),[]).

get_vowel_list()        -> "aeiouy".
get_consonant_list()	->  "bcdfghjklmnopqrstvwxz".

gen_rnd(0,_,_, Res) -> Res;
gen_rnd(Length,	FirstChars, SecondChars,Res) ->
  MaxLength = length(FirstChars),
  M=lists:nth(crypto:rand_uniform(1, MaxLength), FirstChars),
  gen_rnd(Length-1,SecondChars,FirstChars, Res++[M]).

generate_id() -> crypto:rand_uniform(1, 1000).
