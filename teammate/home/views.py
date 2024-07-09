import json
from time import timezone
from django.shortcuts import render
import requests
from django.conf import settings
from django.http import JsonResponse, HttpResponseRedirect
from .models import MyUser, Users, Reviews, Alarms, UserProfiles
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from django.core.files.base import ContentFile
from .forms import ProfileImageForm

@csrf_exempt
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
    profile_image = user_info_json.get('properties').get('profile_image')
    print(id, profile_image)
    
    user_exists = Users.objects.filter(user_id=id).exists()
    if user_exists:
        print("이미 존재하는 사용자입니다.")
    else:
        print("새로운 사용자입니다.")

    user_info = {
        'id': id,
        'profile_image': profile_image,
        'is_exist': user_exists,
    }
    
    if profile_image:
        image_response = requests.get(profile_image)
        if image_response.status_code == 200:
            profile_image_content = ContentFile(image_response.content)

            # Create the UserProfiles instance
            user_profile = UserProfiles(
                user_id_id=id,
            )
            user_profile.profile_image.save(f'{id}.jpg', profile_image_content)
            user_profile.save()
        else:
            print(f"Failed to download image: {profile_image}")
    
    return JsonResponse(user_info)

# @csrf_exempt
# def user_profile(request, user_id):
#     if request.method == 'GET':
#         user_profile = UserProfiles.objects.filter(user_id=user_id).values()
#         if user_profile:
#             return JsonResponse(list(user_profile), safe=False)
#     if request.method in ['POST', 'PUT']:
#         user = get_object_or_404(Users, user_id=user_id)

#         # Check if 'profile_image' is in request.FILES
#         if 'profile_image' not in request.FILES:
#             return JsonResponse({'status': 'error', 'message': 'No profile image provided.'})

#         profile_image = request.FILES['profile_image']
#         form = ProfileImageForm(request.POST, request.FILES)
#         if form.is_valid():
#             user_profile, created = UserProfiles.objects.update_or_create(
#                 user_id=user,
#                 defaults={'profile_image': profile_image}
#             )
#             return JsonResponse({'status': 'success', 'message': 'Profile image updated successfully.'})
#         else:
#             return JsonResponse({'status': 'error', 'message': 'Form is not valid.'})
#     else:
#         return JsonResponse({'status': 'error', 'message': 'Invalid request method.'})
        
@csrf_exempt
def upload_review(request):
    body_unicode = request.body.decode('utf-8')
    body = json.loads(body_unicode)
        
    reviewer_id = body.get('reviewer_id')
    reviewee_id = body.get('reviewee_id')
    score = body.get('score')
    comment = body.get('comment')
    
    created = Reviews.objects.create(
        reviewer_id=reviewer_id,
        reviewee_id=reviewee_id,
        score=score,
        comment=comment,
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
            return JsonResponse(list(reviews))
        else:
            return JsonResponse({'message': 'No review found'})
    else:
        return JsonResponse({'message': 'Invalid request method'})

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

@csrf_exempt
def save_alarm(request):
    if request.method == 'POST':
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        print(body)
        
        receiver_id = body.get('receiver_id')
        type = body.get('type')
        message = body.get('message')
        
        try:
            receiver = Users.objects.get(user_id=receiver_id)
            created = Alarms.objects.create(
                receiver_id=receiver,
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


@csrf_exempt
def select_alarm(request, receiver_id):
    if request.method == 'GET':
        alarm_exists = Alarms.objects.filter(receiver_id=receiver_id)
        if alarm_exists:
            alarms = Alarms.objects.filter(receiver_id=receiver_id).values()
            return JsonResponse(list(alarms), safe=False)
        else:
            return JsonResponse({'message': 'No alarm found'})
    else:
        return JsonResponse({'message': 'Invalid request method'})