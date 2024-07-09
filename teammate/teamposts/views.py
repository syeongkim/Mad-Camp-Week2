from django.forms import model_to_dict
from django.http import JsonResponse, HttpResponseBadRequest
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
import json
from datetime import datetime
from .models import *
from time import timezone

@csrf_exempt
def teamposts(request):
    if request.method == 'POST':
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
            return JsonResponse({'message': 'New post is successfully uploaded'}, safe=False)
        except Exception as e:
            return JsonResponse({'message': 'Failed to upload new post'}, safe=False)
    elif request.method == 'GET':
        posts = TeamPost.objects.all().values().order_by('-created_at').values() # 최신순으로 정렬
        return JsonResponse(list(posts), safe=False)
    else:
        return JsonResponse({'message': 'Invalid request method'}, safe=False)
    
    
def teamposts_course(request, course_id):
    if request.method == 'GET':
        post_exists = TeamPost.objects.filter(course_id=course_id)
        print(post_exists)
        if post_exists:
            posts = TeamPost.objects.filter(course_id=course_id).values().order_by('-created_at').values() # 최신순으로 정렬
            return JsonResponse(list(posts), safe=False)
        else:
            return JsonResponse({'message': 'No post found'})
    else:
        return JsonResponse({'message': 'Invalid request method'})
        
    
@csrf_exempt
def teamposts_post(request, post_id):
    if request.method == 'GET':
        try:
            post = TeamPost.objects.get(post_id=post_id)
            return JsonResponse(model_to_dict(post))
        except TeamPost.DoesNotExist:
            return JsonResponse({'message': 'No post found'})
        
    elif request.method == 'PUT':
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        
        post_title = body.get('post_title')
        course_id = body.get('course_id')
        leader_id = body.get('leader_id')
        post_content = body.get('post_content')
        member_limit = body.get('member_limit')
        due_date = body.get('due_date')
        
        post = get_object_or_404(TeamPost, post_id=post_id, leader_id=leader_id)

        if post_title is not None:
            post.post_title = post_title
        if leader_id is not None:
            post.leader_id = leader_id
        if post_content is not None:
            post.post_content = post_content
        if member_limit is not None:
            post.member_limit = member_limit
        if due_date is not None:
            post.due_date = due_date

        post.save()
        return JsonResponse({'message': 'Post updated successfully'})
    else:
        return JsonResponse({'message': 'Invalid request method'})
    
def teampostdelete(request, post_id, user_id):
    post = get_object_or_404(TeamPost, post_id=post_id, leader_id=user_id)
    post.delete()
    return JsonResponse({'message': 'Post deleted successfully'})
    
def teamrequests(request, request_id):
    if (request.method == 'GET'):
        try:
            request = TeamRequest.objects.get(request_id=request_id)
            return JsonResponse(model_to_dict(request))
        except TeamRequest.DoesNotExist:
            return JsonResponse({'message': 'No post found'})
    elif (request.method == 'POST'):
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        
        try:
            post_id = body.get('post_id')
            leader_id = body.get('leader_id')
            member_id = body.get('member_id')
            request_content = body.get('request_content')
           
            TeamRequest.objects.create(
               post_id=post_id,
               leader_id=leader_id,
               member_id=member_id,
               request_content=request_content,
            )
            return JsonResponse({'message': 'Request is successfully saved'})
        except:
            return JsonResponse({'message': 'Failed to save request'})
    elif (request.method == 'DELETE'):
        request = get_object_or_404(TeamRequest, request_id=request_id)
        request.delete()
        return JsonResponse({'message': 'Request is successfully deleted'})
    else:
        return JsonResponse({'message': 'Invalid request method'})