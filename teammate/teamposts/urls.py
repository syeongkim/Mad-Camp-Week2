from django.urls import path
from .views import *

urlpatterns = [
    path('teamposts', teamposts, name='post'),
    path('courses/<str:course_id>', teamposts_course, name='return_course_post'),
    path('post/<int:post_id>', teamposts_post, name='return_post_detail'),
    path('request/<int:request_id>', teamrequests, name='request_detail'),
    path('myteample/<int:user_id>', myteample, name='myteample'),
    path('myteammember/<int:team_id>', myteammember, name='myteammember')
]