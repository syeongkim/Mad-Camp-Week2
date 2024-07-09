from django.db import models
from home.models import Users

class TeamPost(models.Model):
    post_id = models.AutoField(primary_key=True)
    post_title = models.CharField(max_length=100)
    course_id = models.CharField(max_length=10)
    leader_id = models.BigIntegerField()
    post_content = models.TextField(null=True, blank=True)
    member_limit = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField()

    def __str__(self):
        return str(self.post_id)

class Team(models.Model):
    team_id = models.AutoField(primary_key=True)
    course_id = models.CharField(max_length=10)
    leader_id = models.BigIntegerField()
    is_full = models.BooleanField(default=False)
    is_finished = models.BooleanField(default=False)

    def __str__(self):
        return str(self.team_id)

class TeamMembership(models.Model):
    team_id = models.BigIntegerField(default=None)
    member_id = models.BigIntegerField(default=None)
    joined_at = models.DateTimeField(auto_now_add=True)
    is_finished = models.BooleanField(default=False)

    def __str__(self):
        return f'Team {self.team.team_id} - Member {self.member.user_id}'

class TeamRequest(models.Model):
    request_id = models.AutoField(primary_key=True)
    post_id = models.BigIntegerField()
    leader_id = models.BigIntegerField()
    member_id = models.BigIntegerField()
    request_comment = models.TextField(null=True, blank=True)
    is_accepted = models.BooleanField(default=False)
    requested_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return str(self.request_id)