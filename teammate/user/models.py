from django.db import models
from home.models import Users

# Create your models here.
# class Courses(models.Model):
#     course_id = models.CharField(max_length=10, primary_key=True, unique=True)
#     course_name = models.CharField(max_length=100, default='unknown')
    
#     def __str__(self):
#         return self.course_name
    
# class Skills(models.Model):
#     skill_code = models.AutoField(primary_key=True, unique=True)
#     skill_name = models.CharField(max_length=100, default='unknown')
    
#     def __str__(self):
#         return self.skill_name

# class TakenCourses(models.Model):
#     user_id = models.ForeignKey("home.Users", on_delete=models.CASCADE)
#     course_id = models.ForeignKey(Courses, on_delete=models.CASCADE)

#     def __str__(self):
#         return str(self.user_id)
    
# class UsersSkills(models.Model):
#     user_id = models.ForeignKey("home.Users", on_delete=models.CASCADE)
#     skill_code = models.ForeignKey(Skills, on_delete=models.CASCADE)
    
#     def __str__(self):
#         return str(self.user_id)