{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## formating
    # shfmt
    # treefmt
    # nixfmt

    ## C / C++
    # gcc
    # gdb
    # gef
    # cmake
    # gnumake
    # valgrind
    # llvmPackages_20.clang-tools

    ## Python
    python3
    # python312Packages.ipython
    nodejs_22
    yarn
  ];
}
