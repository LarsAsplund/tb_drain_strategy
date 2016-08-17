from vunit import VUnit
from os.path import dirname, join

vu = VUnit.from_argv()
vu.add_osvvm()
vu.add_com()
vu.add_array_util()
lib = vu.add_library('lib')
lib.add_source_files(join(dirname(__file__), '*.vhd'))
pkg = lib.package('msg_types_pkg')
pkg.generate_codecs(codec_package_name='msg_codecs_pkg')
vu.main()
