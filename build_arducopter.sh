
PATH=$(pwd)/llvm/build/bin:${PATH}

pushd ./ardupilot
./waf distclean
./waf configure --build sitl --check-c-compiler=clang --check-cxx-compiler=clang++
./waf copter
popd
