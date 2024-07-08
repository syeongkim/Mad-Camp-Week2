import json
from django.shortcuts import render
import requests
from django.conf import settings
from django.http import JsonResponse, HttpResponseRedirect
from .models import MyUser

# Create your views here.
# 어제 저녁까지의 코드
# def kakao_callback(request):
#     access_token = request.GET.get('access_token')
#     user_info_url = "https://kapi.kakao.com/v2/user/me"
#     user_info_response = requests.get(
#         user_info_url,
#         headers = {
#             'Authorization': f'Bearer {access_token}'
#         }
#     )
#     user_info_json = user_info_response.json()
#     print(user_info_json)
#     id = user_info_json.get('id')
        
#     debug = MyUser.objects.get(
#         kakao_id=id
#     )
#     print(debug)
        
#     if debug is None:
#         print("새로운 사용자입니다.")
#     else:
#         print("이미 존재하는 사용자입니다.")
        
#     user_info = {
#         'id': id,
#         'is_exist': debug is not None,
#     }

#     return JsonResponse(user_info)

#오늘 아침 코드

def kakao_callback(request):
    access_token = request.GET.get('access_token')
    user_info_url = "https://kapi.kakao.com/v2/user/me"
    user_info_response = requests.get(
        user_info_url,
        headers={
            'Authorization': f'Bearer {access_token}'
        }
    )
    user_info_json = user_info_response.json()
    print(user_info_json)
    id = user_info_json.get('id')

    try:
        debug = MyUser.objects.get(kakao_id=id)
        user_exists = True
        print("이미 존재하는 사용자입니다.")
    except MyUser.DoesNotExist:
        debug = None
        user_exists = False
        print("새로운 사용자입니다.")

    user_info = {
        'id': id,
        'is_exist': user_exists,
    }
    return JsonResponse(user_info)

# # created 함수 사용
# def kakao_callback(request):
#     access_token = request.GET.get('access_token')
#     user_info_url = "https://kapi.kakao.com/v2/user/me"
#     user_info_response = requests.get(
#         user_info_url,
#         headers={
#             'Authorization': f'Bearer {access_token}'
#         }
#     )
#     user_info_json = user_info_response.json()
#     print(user_info_json)
#     id = user_info_json.get('id')
#     nickname = user_info_json.get('properties', {}).get('nickname', 'Unknown')  # 기본 닉네임 설정

#     debug, created = MyUser.objects.get_or_create(
#         kakao_id=id,
#         defaults={'nickname': nickname}
#     )
    
#     if created:
#         print("새로운 사용자입니다.")
#     else:
#         print("이미 존재하는 사용자입니다.")

#     user_info = {
#         'id': id,
#         'is_exist': not created,
#     }

#     return JsonResponse(user_info)

def register(request):
    user_id = request.GET.get('user_id')
    name = request.GET.get('name')
    nickname = request.GET.get('nickname')
    student_id = request.GET.get('student_id')
    
    created = MyUser.objects.create(
        kakao_id=user_id,
        name=name,
        nickname=nickname,
        student_id=student_id
    )
    
    if created:
        return JsonResponse({'message': 'new user is successfully created'})
    else:
        return JsonResponse({'message': 'failed to create new user'})








# import json
# from django.shortcuts import render
# import requests
# from django.conf import settings
# from django.http import JsonResponse, HttpResponseRedirect
# from .models import MyUser

# # Create your views here.
# '''
# def kakao_login(request):
#     kakao_auth_url = 'https://kauth.kakao.com/oauth/authorize'
#     client_id = settings.KAKAO_REST_API_KEY
#     redirect_uri = settings.KAKAO_REDIRECT_URI
#     response_type = "code"
#     return HttpResponseRedirect(f'{kakao_auth_url}?client_id={client_id}&redirect_uri={redirect_uri}&response_type={response_type}')
# '''

# def kakao_callback(request):
#     '''
#     code = request.GET.get('code')
#     kakao_token_url = 'https://kauth.kakao.com/oauth/token'
#     client_id = settings.KAKAO_REST_API_KEY
#     redirect_uri = settings.KAKAO_REDIRECT_URI
#     grant_type = "authorization_code"
    
#     token_response = requests.post(
#         kakao_token_url,
#         data = {
#             'grant_type': grant_type,
#             'client_id': client_id,
#             'redirect_uri': redirect_uri,
#             'code': code,
#         }
#     )
    
#     token_json = token_response.json()
#     print(token_json)
#     '''
#     access_token = request.GET.get('access_token')
#     user_info_url = "https://kapi.kakao.com/v2/user/me"
#     user_info_response = requests.get(
#         user_info_url,
#         headers = {
#             'Authorization': f'Bearer {access_token}'
#         }
#     )
#     user_info_json = user_info_response.json()
#     print(user_info_json)
#     id = user_info_json.get('id')
#     nickname = user_info_json.get('properties').get('nickname')
#     created_at = user_info_json.get('connected_at')
        
#     user, created = MyUser.objects.get_or_create(
#         kakao_id=id, 
#         defaults={'nickname': nickname, 'created_at': created_at}
#     )
#     print(user.nickname)
        
#     if created:
#         print("새로운 사용자입니다.")
#     else:
#         print("이미 존재하는 사용자입니다.")
        
#     user_info = {
#         'id': id,
#         'nickname': nickname,
#         'createdAt': created_at,
#         'is_exist': not created
#     }

#     return JsonResponse(user_info)