from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('oauth', views.oauth_callback, name='oauth_callback'),
]
