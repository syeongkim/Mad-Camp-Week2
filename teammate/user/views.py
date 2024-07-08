import json
from django.http import JsonResponse
from django.shortcuts import get_object_or_404, render
from home.models import Users
from django.views.decorators.csrf import csrf_exempt

# Create your views here.
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
    

def update(request, user_id):
    if user_id is None:
        return JsonResponse({'error': 'user_id parameter is required'}, status=400)

    user = get_object_or_404(Users, user_id=user_id)
    
    user_info = {
        'user_id': user.user_id,
        'name': user.name,
        'nickname': user.nickname,
        'student_id': user.student_id,
        'user_comment': user.user_comment,
        'user_capacity': user.user_capacity,
        'created_at': user.created_at,
    }

    try:
        return JsonResponse(user_info, safe=False) 
    except Exception as e:
        print(e)
        return JsonResponse({"message": "error"}, safe=False) 
