import re
import shutil
from pathlib import Path
import sys
import os
import pwd

class Template(object):
    def __init__(self, src_path):
        self.src_path = Path(src_path)

    @property
    def tar_path(self):
        return SETTINGS_PATH/self.src_path.stem

    def unpack(self):
        if (self.tar_path).exists():
            return
        shutil.copyfile(str(self.src_path), str(self.tar_path))
        sys.stdout.write('unpack template:'+str(self.src_path)+' -> '+str(self.tar_path)+'\n')
        self.fill_by_default_value()

    def fill_by_default_value(self):
        pass

class EnvTemplate(Template):
    TEXT_TEMPLATE = \
"""LAB_UID={uid}
LAB_GID={gid}
LAB_USER={user_name}"""

    def fill_by_default_value(self):
        current_uid = os.getuid()
        pwd_db = pwd.getpwuid(current_uid)
        with self.tar_path.open('w') as f:
            f.write(self.TEXT_TEMPLATE.format(
                    uid=current_uid,
                    user_name=pwd_db.pw_name,
                    gid=pwd_db.pw_gid,
                ))

def unpack_template(template_file_path):
    if str(template_file_path.name) in ['.env.template']:
        print('env')
        EnvTemplate(template_file_path).unpack()
    else:
        Template(template_file_path).unpack()

if __name__ == "__main__":
    SETTINGS_PATH = Path(__file__).parents[1]/'settings'
    TEMPLATES_PATH = SETTINGS_PATH/'templates'

    for template_file_path in TEMPLATES_PATH.glob('./*.template'):
        unpack_template(template_file_path)
