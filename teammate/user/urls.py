from .views import *
from django.urls import path


urlpatterns = [
    path('register', register, name='register'),
    path('update/<int:user_id>', update, name='update'),
    path('edit/<int:user_id>', edit, name='edit'),
    path('view/<int:user_id>', view, name='view'),    
    path('profile/<int:user_id>', user_profile, name='select_profile'),
]

