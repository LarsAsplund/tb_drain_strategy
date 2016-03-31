from vunit import VUnit
from os.path import dirname, join

vu = VUnit.from_argv()
vu.add_osvvm()
vu.add_com()
vu.add_array_util()
lib = vu.add_library('lib')
lib.add_source_files(join(dirname(__file__), '*.vhd'))
vu.main()
