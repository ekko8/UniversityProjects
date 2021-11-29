import csv

countries = []

with open('results.csv') as ResultsData:
    csvReader = csv.reader(ResultsData)
    for row in csvReader:
        if (not(row[1] in countries) and not(row[1] == 'home_team')):
            countries.append(row[1])
        if (not(row[2] in countries) and not(row[2] == 'away_team')):
            countries.append(row[2])

with open('countries.csv', 'w') as output:
    write = csv.writer(output, dialect='unix')
    for country in sorted(countries):
        write.writerow([country])

print ("Created countries.csv")
