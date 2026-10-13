import os
import subprocess

for f in os.listdir('.'):
    if f.endswith('.mp4'):
        size = os.path.getsize(f)
        print(f'File: {f}, Size: {size}')

