from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

# Create your models here.
class MyUserManager(BaseUserManager):
    def create_user(self, kakao_id, nickname, **extra_fields):
        if not kakao_id:
            raise ValueError('The Kakao ID must be set')
        user = self.model(kakao_id=kakao_id, nickname=nickname, **extra_fields)
        user.save(using=self._db)
        return user

class MyUser(AbstractBaseUser):
    kakao_id = models.CharField(max_length=255, unique=True)
    nickname = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    
    objects = MyUserManager()
    
    USERNAME_FIELD = 'kakao_id'
    REQUIRED_FIELDS = ['nickname', 'created_at']

    def __str__(self):
        return str(self.kakao_id)
    
class Courses(models.Model):
    course_id = models.CharField(max_length=10, primary_key=True, unique=True)
    course_name = models.CharField(max_length=100)
    
    def __str__(self):
        return str(self.course_id)
    
class Skills(models.Model):
    skill_id = models.AutoField(primary_key=True, unique=True)
    skill_name = models.CharField(max_length=100)
    
    def __str__(self):
        return str(self.skill_id)
    
class Users(models.Model):
    user_id = models.BigIntegerField(primary_key=True, unique=True)
    name = models.CharField(max_length=20)
    nickname = models.CharField(max_length=20, unique=True)
    student_id = models.IntegerField(default=None, unique=True)
    course_taken_id = models.ForeignKey(Courses, on_delete=models.RESTRICT, related_name='courses_taken', null=True, blank=True)
    skill_id = models.IntegerField(Skills, null=True, blank=True)
    user_comment = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return str(self.user_id)
    
class Reviews(models.Model):
    review_id = models.AutoField(primary_key=True, unique=True)
    reviewer_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='reviewers')
    reviewee_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='reviewees')
    score = models.FloatField()
    content = models.TextField(null=True, blank=True)
    
    def __str__(self):
        return str(self.review_id)