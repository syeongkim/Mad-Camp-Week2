# forms.py
from django import forms
from .models import UserProfiles

class ProfileImageForm(forms.ModelForm):
    class Meta:
        model = UserProfiles
        fields = ['profile_image']
