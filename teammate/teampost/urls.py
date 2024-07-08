from django.urls import path
from teampost.views import upload_post, return_post

urlpatterns = [
    path('teamposts', upload_post, name='upload_post'),
    path('teamposts', return_post, name='return_post')
]