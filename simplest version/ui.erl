-module(ui).
-import(controller, [gen_emp/1, show_emp/0, simulation/0]).

% Export all functions------------------------------------------------
-export([start/0, implement/1]).

% Initialization------------------------------------------------------
-define(second, 1000).

%% function write from here-------------------------------------------

%% implement option---------------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
implement(0) ->
	{ok, stop};

implement(1) ->
	N = 
		try 
			{ok, [Number]} = io:fread("Number of employees : ", "~d"),
			Number
		catch
			_:_ -> 
				io:format("You must write a number~n"),
				implement(1)
		end,
	controller:gen_emp(N),
	timer:sleep((N+1)*?second),	
	start();

implement(2) ->
	controller:show_emp(),
	timer:sleep(?second),	
	start();

implement(3) ->
	controller:simulation(),
	timer:sleep(?second),
	start();

implement(_) ->
	io:format("There is no kind of option~n"),
	start().


%% start user interface-----------------------------------------------
%%--------------------------------------------------------------------
%%--------------------------------------------------------------------
start() ->
	io:format("~nWellcome to our application~n"),
	io:format("0. Stop program~n"),
	io:format("1. Generate some employees~n"),
	io:format("2. Show all employees and id~n"),
	io:format("3. Simulation~n"),
	N = 
		try 
			{ok, [Number]} = io:fread("Option : ", "~d"),
			Number
		catch
			_:_ -> 
				io:format("You must write a number~n"),
				start()
		end,
	implement(N).

