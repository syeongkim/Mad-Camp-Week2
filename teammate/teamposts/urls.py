from django.urls import path
from .views import upload_post, return_post

urlpatterns = [
    path('upload', upload_post, name='upload_post'),
    path('return', return_post, name='return_post')
]