import json
from time import timezone
from django.shortcuts import render
import requests
from django.conf import settings
from django.http import JsonResponse, HttpResponseRedirect
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from .models import TeamPost

@csrf_exempt
@require_http_methods(["POST"])
def upload_post(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
    
    post_id = body.get('post_id')
    post_title = body.get('post_title')
    course_id = body.get('course_id')
    leader_id = body.get('leader_id')
    post_content = body.get('post_content')
    member_limit = body.get('member_limit')
    due_date = body.get('due_date')
    
    created = TeamPost.objects.create(
        post_id=post_id,
        post_title=post_title,
        course_id=course_id,
        leader_id=leader_id,
        post_content=post_content,
        member_limit=member_limit,
        due_date=due_date,
    )
    
    if created:
        return JsonResponse({'message': 'New post is successfully uploaded'})
    else:
        return JsonResponse({'message': 'Failed to upload new post'})
    
@require_http_methods(["POST"])
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