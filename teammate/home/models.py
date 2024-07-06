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
