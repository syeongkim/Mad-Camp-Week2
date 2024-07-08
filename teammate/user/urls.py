from .views import register, update
from django.urls import path


urlpatterns = [
    path('register', register, name='register'),
    path('update/<int:user_id>', update, name='update')
]

