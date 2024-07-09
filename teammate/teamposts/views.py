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
                leader_id=leader_id,
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
    
@csrf_exempt
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
    
@csrf_exempt
def teampostdelete(request, post_id, user_id):
    if request.method == 'DELETE':
        post = get_object_or_404(TeamPost, post_id=post_id, leader_id=user_id)
        post.delete()
        return JsonResponse({'message': 'Post deleted successfully'})
    else:
        return JsonResponse({'message': 'invalid request type'})

@csrf_exempt
def teamrequests(request, request_id):
    if (request.method == 'GET'):
        try:
            request = TeamRequest.objects.get(request_id=request_id)
            return JsonResponse(model_to_dict(request))
        except TeamRequest.DoesNotExist:
            return JsonResponse({'message': 'No post found'})
    elif (request.method == 'PUT'):
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        
        is_accepted = body.get('is_accepted')
        accepted_at = body.get('accepted_at')
        
        request = get_object_or_404(TeamRequest, request_id=request_id)
        
        if is_accepted is not None:
            request.is_accepted = is_accepted
        if accepted_at is not None:
            request.accepted_at = accepted_at
        
        request.save()
        return JsonResponse({'message': 'Request is successfully updated'})
    elif (request.method == 'DELETE'):
        request = get_object_or_404(TeamRequest, request_id=request_id)
        request.delete()
        return JsonResponse({'message': 'Request is successfully deleted'})
    else:
        return JsonResponse({'message': 'Invalid request method'})

@csrf_exempt
def save_request(request):
    if (request.method == 'POST'):
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        
        try:
            post_id = body.get('post_id')
            leader_id = body.get('leader_id')
            member_id = body.get('member_id')
            request_content = body.get('request_content')
           
            request = TeamRequest.objects.create(
               post_id=post_id,
               leader_id=leader_id,
               member_id=member_id,
               request_comment=request_content,
            )
            return JsonResponse({'message': 'Request is successfully saved' + str(request.request_id)}, safe=False)
        except Exception as e:
            return JsonResponse({'message': str(e)})
    else:
        return JsonResponse({'message': 'Invalid request method'})

def myteample(request, user_id):
    print(user_id)
    if request.method == 'GET':
        try:
            user = Users.objects.get(pk=user_id)
        except Users.DoesNotExist:
            return JsonResponse({'error': 'User not found'}, status=404)

        # 사용자가 참여하고 있는 팀의 목록을 가져옵니다.
        memberships = TeamMembership.objects.filter(member_id=user).values()

        # 팀 정보를 가져옵니다.
        teams = []
        for membership in memberships:
            team = membership.team
            try:
                leader = Users.objects.get(pk=team.leader_id)
            except Users.DoesNotExist:
                leader_name = "Unknown"  # 리더가 없는 경우 처리
            else:
                leader_name = leader.name  # Users 모델에 username 필드가 있다고 가정합니다.
            
            teams.append({
                "team_id": team.team_id,
                "course_id": team.course_id,
                "leader_name": leader_name,
                "is_full": team.is_full,
                "is_finished": team.is_finished
            })
            print(teams)

        # JSON 형식으로 응답합니다.
        return JsonResponse(teams, safe=False)

def myteammember(requset, team_id):
    try:
        # 팀 아이디를 통해 팀 멤버십을 찾습니다.
        memberships = TeamMembership.objects.filter(team_id=team_id)
        if not memberships.exists():
            return JsonResponse({'error': 'No members found for this team'}, status=404)
        
        # 팀 멤버십을 통해 유저 정보를 가져옵니다.
        members = []
        for membership in memberships:
            user = membership.member  # TeamMembership 모델에 member 필드가 있다고 가정합니다.
            members.append({
                'user_id': user.user_id,
                'name': user.name,
                'student_id': user.student_id
            })
        
        # JSON 형식으로 응답합니다.
        return JsonResponse(members, safe=False)
    
    except TeamMembership.DoesNotExist:
        return JsonResponse({'error': 'Team not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
def team(request, team_id):
    if request.method == 'GET':
        team = Team.objects.get(team_id=team_id)
        return JsonResponse(model_to_dict(team))
    elif request.method == 'PUT':
        try:
        # 요청 본문에서 JSON 데이터를 읽고 파싱합니다.
            data = json.loads(request.body)
            
            # team_id에 해당하는 팀을 가져옵니다.
            team = Team.objects.get(pk=team_id)
            
            # 요청 데이터에 'is_finished' 필드가 있는지 확인합니다.
            if 'is_finished' in data:
                # 'is_finished' 필드를 업데이트합니다.
                team.is_finished = data['is_finished']
                team.save()
                
                # 성공 응답을 반환합니다.
                return JsonResponse({'status': 'success', 'message': 'Team finished successfully'})
            else:
                # 잘못된 데이터에 대한 오류 응답을 반환합니다.
                return JsonResponse({'status': 'error', 'message': 'Invalid data'}, status=400)
        except Team.DoesNotExist:
            # team_id에 해당하는 팀이 없는 경우의 오류 응답을 반환합니다.
            return JsonResponse({'status': 'error', 'message': 'Team not found'}, status=404)
        except Exception as e:
            # 다른 오류에 대한 오류 응답을 반환합니다.
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

@csrf_exempt
def newteam(request):
    if request.method == 'POST':
        body_unicode = request.body.decode('utf-8')
        body = json.loads(body_unicode)
        
        course_id = body.get('course_id')
        leader_id = body.get('leader_id')
        
        try:
            Team.objects.create(
                course_id=course_id,
                leader_id=leader_id,
            )
            return JsonResponse({'message': 'New team is successfully created'})
        except Exception as e:
            return JsonResponse({'message': 'Failed to create new team.' + e})
    else:
        return JsonResponse({'message': 'Invalid request method'})
