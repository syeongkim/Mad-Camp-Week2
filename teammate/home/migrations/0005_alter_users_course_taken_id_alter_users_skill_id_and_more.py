# Generated by Django 5.0.6 on 2024-07-08 02:09

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0004_alter_users_course_taken_id_alter_users_skill_id_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='users',
            name='course_taken_id',
            field=models.BigIntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='users',
            name='skill_id',
            field=models.BigIntegerField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='users',
            name='user_comment',
            field=models.TextField(blank=True, null=True),
        ),
    ]
