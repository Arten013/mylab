import re
import shutil
from pathlib import Path
import sys

settings_path = Path(__file__).parents[1]/'settings'
templates_path = settings_path/'templates'

for template in templates_path.glob('./*.template'):
    tar_path = settings_path/template.stem
    if (tar_path).exists():
        continue
    shutil.copyfile(str(template), str(tar_path)) 
    sys.stdout.write('unpack template:'+str(template)+' -> '+str(tar_path)+'\n')
        
