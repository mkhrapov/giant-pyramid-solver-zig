# Giant Pyramid solver in Zig

Code generated by Claude Sonnet 4 based on my C code. Initially it had a few compilation issues and some bugs, but with a few additional prompts, it got fixed. Zig optimized binary seems to run faster than my Go, C, and Rust versions.

```
zig build -Doptimize=ReleaseFast
```


```
% time ./giant_pyramid_solver_zig 
Precompute: 0.006301 sec
Search: 2.275 sec
Choices:
0 216 81 24 157 26 33 65 89
1 1 1 4 3 6 7 4 3 2 7 8 2 7 2 6 6 6 3 2 4 9 4 8 7 5 5 3 8 9 8 9 5 9 5
./giant_pyramid_solver_zig  2.28s user 0.01s system 93% cpu 2.444 total
```
