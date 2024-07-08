import requests
from bs4 import BeautifulSoup

response = requests.get('https://cs.kaist.ac.kr/education/undergraduate')
soup = BeautifulSoup(response.text, 'html.parser')

course_list = []
course_name = soup.select('strong.subject')
for course in course_name:
    course_code = course.find_parent('tr').find_all('td')[0].text.strip()
    course_list.append({
        'course_code': course_code,
        'course_name': course.text.strip(),
    })

print(course_list)
