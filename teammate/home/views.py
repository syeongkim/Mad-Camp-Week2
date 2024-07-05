from django.shortcuts import redirect
from django.http import JsonResponse
import requests

def oauth_callback(request):
    code = request.GET.get('code')
    if not code:
        return JsonResponse({'error': 'No code provided'}, status=400)

    # 카카오 토큰 요청
    token_url = 'https://kauth.kakao.com/oauth/token'
    redirect_uri = 'http://localhost:3306/oauth'
    client_id = 'fc4e17c0c5767418fa3e29c02271c49a'  # 카카오 디벨로퍼스 콘솔에서 발급받은 REST API 키
    #client_secret = 'YOUR_CLIENT_SECRET'  # (선택 사항) 카카오 디벨로퍼스 콘솔에서 설정한 client secret

    data = {
        'grant_type': 'authorization_code',
        'client_id': client_id,
        'redirect_uri': redirect_uri,
        'code': code,
        #'client_secret': client_secret,  # (선택 사항)
    }

    response = requests.post(token_url, data=data)
    token_info = response.json()

    if 'access_token' not in token_info:
        return JsonResponse({'error': 'Failed to obtain access token'}, status=400)

    access_token = token_info['access_token']
    return JsonResponse({'access_token': access_token})
