from django.urls import path
from rest_framework import routers
from .views import HealthCheckView, UserViewSet

router = routers.DefaultRouter()
router.register('users', UserViewSet, 'users')

urlpatterns = [
    path('health/', HealthCheckView.as_view(), name='health'),
] + router.urls