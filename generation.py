import pandas

data = pandas.read_csv('donnees.csv')

print(data.head())

start_time = 0
duration = 4

print("Data sonification GO!")

for index, row in data.iterrows():
    print('i1'+ "   " +  str(start_time) + '   ' + str(duration) + '   ' + str(round(row['Valeur']*100.00)))
    start_time += duration

