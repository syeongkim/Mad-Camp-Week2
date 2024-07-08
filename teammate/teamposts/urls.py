from django.urls import path
from .views import *

urlpatterns = [
    path('teamposts', teamposts, name='post'),
    path('teamposts/<str:course_id>', teamposts_course, name='return_course_post'),
    path('teamposts/<int:post_id>', teamposts_post, name='return_post_detail'),
    path('request/<int:request_id>', teamrequests, name='request_detail'),
]