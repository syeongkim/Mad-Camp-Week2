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
    
from django.db import models

class UserProfiles(models.Model):
    kakao_id = models.BigIntegerField(primary_key=True, unique=True)
    profile_image = models.ImageField(upload_to='profile_images/', null=True, blank=True)
    
    def __str__(self):
        return str(self.kakao_id)

class Users(models.Model):
    user_id = models.BigIntegerField(primary_key=True, unique=True)
    name = models.CharField(max_length=20, default='unknown')
    nickname = models.CharField(max_length=20, default='unknown')
    student_id = models.IntegerField(default=None, unique=True, null=True, blank=True)
    user_comment = models.TextField(null=True, blank=True, default="각오 한마디")
    user_capacity = models.TextField(null=True, blank=True, default="들은 과목과 기술 스택, 관심사를 적어주세요.")
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.user_id

    
class Reviews(models.Model):
    review_id = models.AutoField(primary_key=True, unique=True)
    reviewer_id = models.BigIntegerField()
    reviewee_id = models.BigIntegerField()
    score = models.FloatField()
    content = models.TextField(null=True, blank=True)
    
    def __str__(self):
        return str(self.review_id)

class Alarms(models.Model):
    alarm_id = models.AutoField(primary_key=True, unique=True)
    receiver_id = models.BigIntegerField()
    type = models.CharField(max_length=20)
    message = models.TextField()
    read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return str(self.alarm_id)

    
class CourseList(models.Model):
    course_code = models.CharField(max_length=20, primary_key=True, unique=True)
    course_name = models.CharField(max_length=20)
    
    def __str__(self):
        return str(self.course_id)