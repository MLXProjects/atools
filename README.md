# Latools
Libaroma tools & dependencies for easy building (using legacy-like build system)
## How to use
Set up config.txt:  
- set LIBAROMA_SOURCE to wherever you've downloaded main libaroma repository
- set LIBAROMA_GCC/LIBAROMA_AR with paths to the compiler you already have (because you have it, right?)
- modify LIBAROMA_PLATFORM, CPU, etc. to what you need
- enable what you need, the provided config.txt builds a minimal version of libaroma :)  

Build libaroma dependencies by running alibs.cmd, it will create an out folder with libraries  
Build libaroma by running abuild.cmd, if you didn't build libraries it will do so automatically  
Build any C source by running atest.cmd <path/to/folder/containing/source>, for example  
- atest.cmd D:\projects\test (where test folder contains asd.c)  

It will output a binary/executable file at the out-\<platform\> folder (e.g. out-linux) with the name of the folder you've built.  
If you've set LIBAROMA_CPU in config.txt, out folder will be out-\<platform\>_\<cpu\> (e.g. out-linux_neon).
