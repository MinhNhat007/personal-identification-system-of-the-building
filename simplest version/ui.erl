-module(ui).
-import(controller, [gen_emp/1, show/0]).

% Export all functions------------------------------------------------
-export([start/0, implement/1]).

%% function write from here-------------------------------------------

%% implement option---------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
implement(1) ->
	{ok, [N]} = io:fread("Number of employees : ", "~d"),
	controller:gen_emp(N),
	timer:sleep((N+1)*1000),	
	start();

implement(2) ->
	controller:show(),
	timer:sleep(1000),	
	start();

implement(_) ->
	{ok, stop}.


%% start user interface-----------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
start() ->
	io:format("~nWellcome to our application~n"),
	io:format("1. Generate some employees~n"),
	io:format("2. Show all employees and id ~n"),
	{ok, [N]} = io:fread("Option : ", "~d"),
	implement(N).
