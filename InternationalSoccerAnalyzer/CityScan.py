import csv

cities = []

with open('results.csv') as ResultsData:
    csvReader = csv.reader(ResultsData)
    for row in csvReader:
        if (not(row[6] in cities) and not(row[6] == 'city')):
            cities.append(row[6])

with open('cities.csv', 'w') as output:
    write = csv.writer(output, dialect='unix')
    for city in sorted(cities):
        write.writerow([city])

print ("Created cities.csv")
