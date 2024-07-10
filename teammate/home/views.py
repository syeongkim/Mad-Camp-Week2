import json
import requests
from django.http import JsonResponse
from .models import *
from django.views.decorators.csrf import csrf_exempt
from django.core.files.base import ContentFile

@csrf_exempt  # CSRF 보호 비활성화 (필요에 따라 적용)
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
def upload_review(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
        
    reviewer_id = body.get('reviewer_id')
    reviewee_id = body.get('reviewee_id')
    score = body.get('score')
    comment = body.get('comment')
    
    #reviewer_id = Users.objects.get(user_id=reviewer_id)
    #reviewee_id = Users.objects.get(user_id=reviewee_id)
        
    created = Reviews.objects.create(
        reviewer_id=reviewer_id,
        reviewee_id=reviewee_id,
        score=score,
        content=comment,
    )
    
    if created:
        return JsonResponse({'message': 'new review is successfully uploaded'})
    else:
        return JsonResponse({'message': 'failed to upload new review'})

@csrf_exempt
def select_reviews(request, reviewee_id):
    if request.method == 'GET':
        review_exists = Reviews.objects.filter(reviewee_id=reviewee_id)
        if review_exists:
            reviews = Reviews.objects.filter(reviewee_id=reviewee_id).values()
            return JsonResponse(list(reviews), safe=False)
        else:
            return JsonResponse({'message': 'No review found'}, status=404)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status=404)
# @csrf_exempt
# def save_alarm(request):
#     if request.method == 'POST':
#         body_unicode = request.body.decode('utf-8')
#         body = json.loads(body_unicode)
#         print(body)
        
#         receiver_id = body.get('receiver_id')
#         type = body.get('type')
#         message = body.get('message')
        
#         created = Alarms.objects.create(
#             receiver_id=receiver_id,
#             type=type,
#             message=message,
#         )
        
#         if created:
#             return JsonResponse({'message': 'new alarm is successfully saved'})
#         else:
#             return JsonResponse({'message': 'failed to save new alarm'})
#     else:
#         return JsonResponse({'message': 'Invalid request method'})
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Alarms, Users
from teamposts.models import TeamPost

@csrf_exempt
def save_alarm(request):
    if request.method == 'POST':
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        print(body)
        
        receiver_id = body.get('receiver_id')
        sender_id = body.get('sender_id')
        post_id = body.get('post_id')
        type = body.get('type')
        sender = Users.objects.get(user_id=sender_id)
        sender_name = sender.name
        post = TeamPost.objects.get(post_id=post_id)
        course_id = post.course_id
        course = CourseList.objects.get(course_code=course_id)
        course_name = course.course_name
        
        if type == 'request':
            message = f'{sender_name}님이 {course_name} 함께하기 요청을 보냈습니다.'
        elif type == 'accept':
            message = f'{sender_name}님이 {course_name} 함께하기 요청을 수락했습니다.'
        elif type == 'reject':
            message = f'{sender_name}님이 {course_name} 함께하기 요청을 거절했습니다.'
        
        try:
            receiver = Users.objects.get(user_id=receiver_id)
            created = Alarms.objects.create(
                receiver_id=receiver_id,
                sender_id=sender_id,
                post_id=post_id,
                type=type,
                message=message,
            )
            
            if created:
                return JsonResponse({'message': 'new alarm is successfully saved'})
            else:
                return JsonResponse({'message': 'failed to save new alarm'})
        except Users.DoesNotExist:
            return JsonResponse({'message': 'User not found'}, status=404)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status=405)

def read_alarm(request, alarm_id):
    if request.method == 'PUT':
        alarm = Alarms.objects.get(alarm_id=alarm_id)
        alarm.read = True
        alarm.save()
        return JsonResponse({'message': 'alarm is successfully marked as read'})
    else:
        return JsonResponse({'message': 'Invalid request method'}, status = 404)

@csrf_exempt
def select_alarm(request, receiver_id):
    if request.method == 'GET':
        alarm_exists = Alarms.objects.filter(receiver_id=receiver_id)
        if alarm_exists:
            alarms = Alarms.objects.filter(receiver_id=receiver_id).order_by('-created_at').values()
            return JsonResponse(list(alarms), safe=False)
        else:
            return JsonResponse({'message': 'No alarm found'}, status = 404)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status = 404)
