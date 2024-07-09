# Generated by Django 5.0.6 on 2024-07-09 16:26

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('home', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Team',
            fields=[
                ('team_id', models.AutoField(primary_key=True, serialize=False)),
                ('course_id', models.CharField(max_length=10)),
                ('is_full', models.BooleanField(default=False)),
                ('is_finished', models.BooleanField(default=False)),
                ('leader_id', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='leader_teams', to='home.users')),
            ],
        ),
        migrations.CreateModel(
            name='TeamPost',
            fields=[
                ('post_id', models.AutoField(primary_key=True, serialize=False)),
                ('post_title', models.CharField(max_length=100)),
                ('course_id', models.CharField(max_length=10)),
                ('post_content', models.TextField(blank=True, null=True)),
                ('member_limit', models.IntegerField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('due_date', models.DateTimeField()),
                ('leader_id', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='leader_posts', to='home.users')),
            ],
        ),
        migrations.CreateModel(
            name='TeamRequest',
            fields=[
                ('request_id', models.AutoField(primary_key=True, serialize=False)),
                ('request_comment', models.TextField(blank=True, null=True)),
                ('is_accepted', models.BooleanField(default=False)),
                ('requested_at', models.DateTimeField(auto_now_add=True)),
                ('accepted_at', models.DateTimeField(blank=True, null=True)),
                ('leader_id', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='requests_as_leader', to='home.users')),
                ('member_id', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='requests_as_member', to='home.users')),
                ('post_id', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='requests_post_id', to='teamposts.teampost')),
            ],
        ),
        migrations.CreateModel(
            name='TeamMembership',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('joined_at', models.DateTimeField(auto_now_add=True)),
                ('is_finished', models.BooleanField(default=False)),
                ('member', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='team_memberships', to='home.users')),
                ('team', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, related_name='memberships', to='teamposts.team')),
            ],
            options={
                'unique_together': {('team', 'member')},
            },
        ),
    ]
