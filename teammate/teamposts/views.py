from django.http import JsonResponse, HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime
from .models import TeamPost
from time import timezone

@csrf_exempt  # 나중에 적절한 CSRF 처리가 필요할 수 있습니다
def upload_post(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    
    post_title = body.get('post_title')
    course_id = body.get('course_id')
    leader_id = body.get('leader_id')
    post_content = body.get('post_content')
    member_limit = body.get('member_limit')
    due_date = body.get('due_date')

    try:
        TeamPost.objects.create(
            post_title=post_title,
            course_id=course_id,
            leader_id_id=leader_id,
            post_content=post_content,
            member_limit=member_limit,
            due_date=due_date,
        )
        return JsonResponse({'message': 'New post is successfully uploaded'})
    except Exception as e:
        return HttpResponseBadRequest(f'Failed to upload new post: {str(e)}')

    
def return_post(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    
    course_id = body.get('course_id')
    
    post_exists = TeamPost.objects.filter(course_id=course_id)
    
    if post_exists:
        posts = TeamPost.objects.all().values()
        return JsonResponse(list(posts))
    else:
        return JsonResponse({'message': 'No post found'})