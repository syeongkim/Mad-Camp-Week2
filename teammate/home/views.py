from django.shortcuts import render
import requests
from django.conf import settings
from django.http import JsonResponse, HttpResponseRedirect
from .models import MyUser

# Create your views here.
def kakao_login(request):
    kakao_auth_url = 'https://kauth.kakao.com/oauth/authorize'
    client_id = settings.KAKAO_REST_API_KEY
    redirect_uri = settings.KAKAO_REDIRECT_URI
    response_type = "code"
    return HttpResponseRedirect(f'{kakao_auth_url}?client_id={client_id}&redirect_uri={redirect_uri}&response_type={response_type}')

def kakao_callback(request):
    code = request.GET.get('code')
    kakao_token_url = 'https://kauth.kakao.com/oauth/token'
    client_id = settings.KAKAO_REST_API_KEY
    redirect_uri = settings.KAKAO_REDIRECT_URI
    grant_type = "authorization_code"
    
    token_response = requests.post(
        kakao_token_url,
        data = {
            'grant_type': grant_type,
            'client_id': client_id,
            'redirect_uri': redirect_uri,
            'code': code,
        }
    )
    
    token_json = token_response.json()
    access_token = token_json.get('access_token')
    if access_token:
        user_info_url = "https://kapi.kakao.com/v2/user/me"
        user_info_response = requests.get(
            user_info_url,
            headers = {
                'Authorization': f'Bearer {access_token}'
            }
        )
        user_info_json = user_info_response.json()
        id = user_info_json.get('id')
        nickname = user_info_json.get('properties').get('nickname')
        created_at = user_info_json.get('kakao_account').get('created_at')
        
        user, created = MyUser.objects.get_or_create(
            kakao_id=id, 
            defaults={'nickname': nickname, 'created_at': created_at}
        )
        
        print(user, created)
        
        user_info = {
            'id': id,
            'nickname': nickname,
            'createdAt': created_at
        }
        return JsonResponse(user_info)
    else:
        return JsonResponse(token_json)