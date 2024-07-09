from django.db import models
from home.models import Users

class TeamPost(models.Model):
    post_id = models.AutoField(primary_key=True)
    post_title = models.CharField(max_length=100)
    course_id = models.CharField(max_length=10)
    leader_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='leader_posts')
    post_content = models.TextField(null=True, blank=True)
    member_limit = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField()

    def __str__(self):
        return str(self.post_id)

class Team(models.Model):
    team_id = models.AutoField(primary_key=True)
    course_id = models.CharField(max_length=10)
    leader_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='leader_teams')
    is_full = models.BooleanField(default=False)
    is_finished = models.BooleanField(default=False)

    def __str__(self):
        return str(self.team_id)

class TeamMembership(models.Model):
    team = models.ForeignKey(Team, on_delete=models.RESTRICT, related_name='memberships')
    member = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='team_memberships')
    joined_at = models.DateTimeField(auto_now_add=True)
    is_finished = models.BooleanField(default=False)

    class Meta:
        unique_together = ('team', 'member')

    def __str__(self):
        return f'Team {self.team.team_id} - Member {self.member.user_id}'

class TeamRequest(models.Model):
    request_id = models.AutoField(primary_key=True)
    post_id = models.ForeignKey(TeamPost, on_delete=models.RESTRICT, related_name='requests_post_id')
    leader_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='requests_as_leader')
    member_id = models.ForeignKey(Users, on_delete=models.RESTRICT, related_name='requests_as_member')
    request_comment = models.TextField(null=True, blank=True)
    is_accepted = models.BooleanField(default=False)
    requested_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return str(self.request_id)