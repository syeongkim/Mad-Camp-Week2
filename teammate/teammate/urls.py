"""
URL configuration for teammate project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path
from home.views import *
# from home.views import register
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('admin/', admin.site.urls),
    path('oauth/callback', kakao_callback, name='kakao_callback'),
    path('reviews', upload_review, name='upload_review'),
    path('reviews/<int:reviewee_id>', select_reviews, name='select_reviews'),
    path('alarm', save_alarm, name='save_alarm'),
    path('alarm/<int:receiver_id>', select_alarm, name='select_alarm'),
    path('user/profile/<int:user_id>', user_profile, name='select_profile'),
    # path('user/register', register, name='register'),
    path('user/', include('user.urls')),
    path('teamposts/', include('teamposts.urls'))
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)