import sys
import os

# Ensure server module imports work
current_dir = os.path.dirname(os.path.abspath(__file__))
server_dir = os.path.join(current_dir, '../server')
sys.path.append(server_dir)

from app import app
