import json

names = [
    'Alyson Alston', 'Marleigh Hurst', 'Adalyn Capps', 'Abilene Berkeley',
    'Marlin Locklin', 'Marlow Wall', 'Elder Guy', 'Nola Gresham',
    'Talia Richards', 'Kirstan Toman', 'Maribelle Grove', 'Sasha Kirkland',
    'Zoee Kimbrough', 'Cailey Heaton', 'Ellamarie Wathen', 'Aileen Wilkerson',
    'Johannah May', 'Ghadeer Sheehan', 'Daisia Keene', 'Amari Fenske',
    'Alissah Minton', 'Nova Logan', 'Amaia Glover', 'Lakai Vanover',
    'Christion Grove'
]

myObj = {
    "names": str(names),
}

print(json.dumps(myObj))
