proc import datafile = "E:\SAS\PG2\data/ATP.csv" dbms = csv out = ATP; /* 1a */
run;

proc contents data = ATP varnum;   /* 1b */
run;

proc print data = ATP (obs = 10); /* 3a 3c */
var round score surface match_num winner_name; /* 3b */
where winner_name like "%Federer"; /* 3d */
format round $4. match_num 3.; /* 3e */
run;

data ATP_new;
set ATP; /* 5a */
length older_better $ 3; /* 5e */
keep loser_name loser_age match_num winner_age winner_name winner_ht 
loser_ht score set_num older_better; /* 5c */
where best_of = 5 & surface = "Grass" & winner_age is not null 
& loser_age is not null & winner_ht is not null & loser_ht is not null; /* 5b */
format winner_age loser_age 2.; /* 5d */
if countw(score," ") >= 3 then set_num = countw(score," "); /* 5f */
if winner_age > loser_age then older_better = "Yes";
else older_better = "No";
if set_num in (3,4,5);
run;

proc print data = ATP_new (obs = 5); run;


data ATP_1;
set ATP;
length local_winner $ 5;
length Right_hand $ 5;
if winner_hand = 'R' then Right_hand = 'True'; /* 6a */
else Right_hand = 'False';
if tourney_name = 'Australian Chps.' & winner_ioc = 'AUS' then local_winner = 'True';/* 6b */
else if tourney_name = 'Australian Chps.'& winner_ioc ne 'AUS' then local_winner = 'False';
if winner_age < 25 then do; /* 6c */
winner_group = 'young age';
winner_future = 'bright';
end;


proc print data = ATP_1 (obs = 10);
var winner_group winner_future local_winner Right_hand;
where tourney_name = 'Australian Chps.' & winner_age < 25;
run;



%let A = ATP information; /* 7d */
%let B = player and set information; /* 7d */
title "&A";/* 7a */
title2 "&B";/* 7b */
footnote "ATP players with age and set number";/* 7c */
proc print data = ATP_new (obs =10) label; /* 7e */
var set_num older_better;
label set_num = "Number of sets player win the game" older_better = "Older player win the game";
run;
title; /* 7f */
footnote; /* 7f */

proc freq data = ATP_new order = freq; /* 8a */
tables winner_age;
run;
proc freq data = ATP_new order = freq; /* 8b */
tables winner_age*set_num / nocol norow nopercent;
format winner_age 2.;
run;

proc sql;
create table ATP_sql as /* 12a */
select loser_name, winner_name, score, older_better, set_num
from ATP_new 
where older_better = "Yes" /* 12b */
order by set_num, winner_name desc; /* 12c */
quit; 

proc print data = ATP_sql (obs = 10); run;

proc sort data = ATP out = ATP1; /* 15d */
by tourney_id;
run;

data ATP_sum; 
set ATP1;
by tourney_id;
keep matches accumulated_matches ;
retain matches; /* 15a */
if first.tourney_id = 1 then do; /* 15c */
matches = 0;
accumulated_matches = 0;
end;
matches = matches+1; 
accumulated_matches+matches; /* 15b */
run;
proc print data = ATP_sum (obs = 10); run;

data ATP_mod;
set ATP_new;
Lastname = scan(winner_name,-1); /* 18c */
First_set = substr(score,1,3); /* 18a */
winner_name = propcase(winner_name); /* 18d */
loser_name = lowcase(loser_name); /* 18e */
Namelength = length(winner_name); /* 18b */
if older_better = 'Yes' then Age_name = cats(winner_name, ',', 
round(winner_age,1),',', 'older wins'); /* 18f */
else Age_name = cats(winner_name, ',', round(winner_age,1),
',', 'younger wins');
run;

proc print data = ATP_mod(obs = 10); run;

data ATP;
set ATP;
if countw(score," ") >= 3 then set_num = countw(score," ");
run;

libname pg2 base 'E:\SAS\PG2\data';
proc format library = pg2.hwformats; /* 22c */
value game 3 = 'Quick Game'  /* 22b */
	  	   4 = 'Median Game'
	  	   5 = 'Long Game';
value $field "Grass", "Hard" = "Fast"  /* 22a */
	   		 "Carpet", "Clay" = "Slow";
run;

options fmtsearch = (pg2.hwformats);
proc freq data = ATP;  /* 22d */
tables surface set_num;
format surface $field. set_num game.;
run;




