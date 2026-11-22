#!/bin/sh
# Inicialização no Cloud Run: aplica migrações, cria o administrador e os
# dados iniciais só se o banco estiver vazio, e sobe o servidor de produção.
set -e
python manage.py migrate --noinput
python manage.py shell -c "
import os
from django.contrib.auth import get_user_model
from django.core.management import call_command
from eventos.models import Categoria

Usuario = get_user_model()
usuario = os.getenv('ADMIN_USUARIO')
senha = os.getenv('ADMIN_SENHA')
if usuario and senha and not Usuario.objects.filter(username=usuario).exists():
    Usuario.objects.create_superuser(
        username=usuario,
        email=os.getenv('ADMIN_EMAIL', ''),
        password=senha,
        tipo=Usuario.Tipo.ADMINISTRADOR,
    )
    print('Administrador criado:', usuario)

if not Categoria.objects.exists():
    try:
        call_command('loaddata', 'producao')
    except Exception as erro:
        print('Aviso: dados iniciais não carregados:', erro)
"
exec gunicorn core.wsgi:application --bind 0.0.0.0:${PORT:-8080} --workers 2 --timeout 60
