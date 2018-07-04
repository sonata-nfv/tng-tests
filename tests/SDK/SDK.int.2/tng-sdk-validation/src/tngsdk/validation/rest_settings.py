import os

HOST = os.environ.get('VAPI_HOST') or '0.0.0.0'
PORT = os.environ.get('VAPI_PORT') or 5050
REDIS_HOST = os.environ.get('VAPI_REDIS_HOST') or '0.0.0.0'
REDIS_PORT = os.environ.get('VAPI_REDIS_PORT') or '6379'
REDIS_USER = os.environ.get('VAPI_REDIS_USER') or 'redis'
REDIS_PASSWD = os.environ.get('VAPI_REDIS_PASSWORD') or ''
CACHE_TYPE = os.environ.get('VAPI_CACHE_TYPE') or 'redis'
ARTIFACTS_DIR = os.environ.get('VAPI_ARTIFACTS_DIR') or \
                os.path.join(os.getcwd(), 'artifacts')

DEBUG = os.environ.get('VAPI_DEBUG') or False
ENABLE_CORS = os.environ.get('ENABLE_CORS') or False
