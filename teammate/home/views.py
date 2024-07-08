import json
from time import timezone
from django.shortcuts import render
import requests
from django.conf import settings
from django.http import JsonResponse, HttpResponseRedirect
from .models import MyUser, Users
from django.views.decorators.csrf import csrf_exempt

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
    
    user_exists = Users.objects.filter(user_id=id).exists()
    if user_exists:
        print("이미 존재하는 사용자입니다.")
    else:
        print("새로운 사용자입니다.")

    user_info = {
        'id': id,
        'is_exist': user_exists,
    }
    return JsonResponse(user_info)

@csrf_exempt
def register(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
        
    user_id = body.get('user_id')
    name = body.get('user_name')
    nickname = body.get('user_nickname')
    student_id = body.get('user_student_id')
    
    created = Users.objects.create(
        user_id=user_id,
        name=name,
        nickname=nickname,
        student_id=student_id,
    )
    
    if created:
        return JsonResponse({'message': 'new user is successfully created'})
    else:
        return JsonResponse({'message': 'failed to create new user'})