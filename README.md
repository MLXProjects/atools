# atools
Libaroma tools & dependencies for easy building (using legacy-like build system)
## How to use
Set up config.txt:  
- set `LIBAROMA_SOURCE` to wherever you've downloaded main libaroma repository
- set `LIBAROMA_GCC` and `LIBAROMA_AR` with paths to the compiler you already have (because you have it, right?)
- modify `LIBAROMA_PLATFORM`, `LIBAROMA_CPU`, etc. to what you need
- enable what you need, the provided config.txt builds a minimal version of libaroma :)  

To build libaroma dependencies `run alibs.cmd`, it will create an out folder with libraries.  
To build libaroma run `abuild.cmd`, if you didn't build libraries it will do so automatically.  
You can also build C source from any folder by running `atest.cmd <path/to/folder/containing/source>`, for example:  

`atest.cmd D:\projects\test (where test folder contains asd.c)`  

It will output a binary/executable file at the out folder with the name of the folder you've built.  

## Advanced usage
### Specific configs
If you want to build for multiple platforms, you can use custom config files and specify which one to use at build time.  
To do this, create a `config-<configname>.txt` and pass it's `<configname>` as the first argument in any build script.  
For example, to use the included `config-win.txt`:

`abuild.cmd win`  

This will build libaroma and dependencies using the `config-win.txt` file as settings source.

### Output folders
By default, build system will create a folder called `out-<platform>` (for example, `out-linux`).  
If you've set `LIBAROMA_CPU` in config file, out folder will be `out-<platform>_<cpu>` (for example, `out-linux_neon`).  
If you're using a custom config file, it's name will be used instead of platform (for example, `out-win_ssse3`). Note that `LIBAROMA_CPU` is still used in this case.  
At the time of writing, it's not possible to set custom out directories because I didn't find it useful :P  

### Build individual libraries 
alibs.cmd builds needed libraries by reading config and outputting a libadeps.a in out folder.  
You may need to build specific libraries (for example, you've updated one of them), to do so:  

`alibs.cmd <libnames>` (for example, `alibs.cmd zlib`)

Where `<libnames>` corresponds to a list of libraries to be built.  
You can also pass the config name first in order to use a specific config file:  

`alibs.cmd <configname> <libnames>` (for example, `alibs.cmd win zlib`)

Where `<configname>` is the suffix of the config file you want to use.  
It will detect that you're passing a config name and will use it.  
Note that a file named `config-<configname>.txt` must exist.
