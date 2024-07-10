from django.contrib import admin
from django.urls import include, path
from home.views import *
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('oauth/callback', kakao_callback, name='kakao_callback'),
    path('reviews', upload_review, name='upload_review'),
    path('reviews/<int:reviewee_id>', select_reviews, name='select_reviews'),
    path('alarm', save_alarm, name='save_alarm'),
    path('alarm/<int:receiver_id>', select_alarm, name='select_alarm'),
    path('alarm/<int:alarm_id>', read_alarm, name='read_alarm'),
    path('user/', include('user.urls')),
    path('teamposts/', include('teamposts.urls'))
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)