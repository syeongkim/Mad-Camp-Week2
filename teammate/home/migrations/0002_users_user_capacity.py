# Generated by Django 5.0.6 on 2024-07-08 16:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='users',
            name='user_capacity',
            field=models.TextField(blank=True, default='comment', null=True),
        ),
    ]
