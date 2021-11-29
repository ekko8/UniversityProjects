# README.md
This application was made for the final project for IT3530 at the University of Missouri. The purpose is to make it easier to analyze the history of International Soccer. It allows the user to see a countries win/loss record, total goals scored, goal differential, and penalty kick shootout record. It also allows the user to view this same data within a specific range of years.

---

## results.csv & shootouts.csv
These data files were downloaded from [here](https://www.kaggle.com/martj42/international-football-results-from-1872-to-2017) results.csv includes every international soccer game ever played since 1872. It includes the date, home team, away team, home score, away score, tournament, host city, host country, and whether or not it was a neutral location. The data may not be up to date in this repository when you are using this. If so you can download the data yourself and include it in the same directory as the scripts.

---

## CityScan.py & CountryScan.py
These python scripts scan the above data files for the city or country names and output them into cities.csv and countries.csv.
**Python3 is required** to run these scripts. But it is not necessary to run them as cities.csv and countries.csv is already included here.

---

## SoccerData.sh
This is the main part of the application. It uses the cities.csv and countries.csv files to list the names of the cities and countries to the user. These files are also used to make sure the user inputs the names properly when selecting a city or country.
