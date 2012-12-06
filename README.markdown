ProgStarter
===========
ProgStarter is a software to start different programs in dependence of Windows architecture (x86 or x64).

Settings
________
Settings stored in ini-file which name matches with exe-name.

### Example1, different progs at different architecture:

[Launch32]
CmdLine=notepad.exe 123.txt
[Launch64]
CmdLine=calc.exe

### Example2, single app:

[Launch]
CmdLine=cmd.exe