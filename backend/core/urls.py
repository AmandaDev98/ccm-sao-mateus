from django.contrib import admin
from django.conf import settings
from django.http import FileResponse, Http404
from django.urls import path, include, re_path
from rest_framework.routers import DefaultRouter

from eventos.views import (
    CategoriaViewSet,
    UsuarioViewSet,
    EventoViewSet,
    InteresseViewSet,
    cadastro,
    login,
)

router = DefaultRouter()

router.register('categorias', CategoriaViewSet)
router.register('usuarios', UsuarioViewSet)
router.register('eventos', EventoViewSet)
router.register('interesses', InteresseViewSet)

urlpatterns = [
    # /admin é uma página do React, então o admin do Django fica em /django-admin/
    path('django-admin/', admin.site.urls),

    path('api/auth/cadastro/', cadastro, name='cadastro'),
    path('api/auth/login/', login, name='login'),

    path('api/', include(router.urls)),
]


def frontend(request):
    # Devolve o index.html do React para as rotas do site (/sobre, /evento/1...)
    index = settings.FRONTEND_DIST / 'index.html'
    if not index.exists():
        raise Http404('Build do frontend não encontrado.')
    return FileResponse(open(index, 'rb'), content_type='text/html')


urlpatterns += [
    re_path(r'^(?!api/|django-admin/|static/).*$', frontend),
]
