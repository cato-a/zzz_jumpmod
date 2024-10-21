# Jump'it Jump Mod

Source code for the Jump'it jump mod. Currently live on the [Jump'it Server](https://cod.pm/server/78.46.106.94/28961).

## Credits

- Code by Cato
- Some 'fun' admin commands based on Cheese's admin commands
- Some 'fun' admin commands based on PowerServer's commands
- [json2gsc](https://github.com/thecheeseman/json2gsc/) tool by Cheese

### Special Thanks

Huepfer, Hehu, Regis, and all the Jump'it team who worked on the project.

## Contributing

New contributions are welcome! Please be sure to follow the [STYLE](STYLE.md) guide when submitting pull requests with changes.

## Build Instructions

### Tools Required

- Linux distro
- C++ compiler w/ C++20 support
- CMake 3.19 or higher

#### Debian and variants

```plaintext
apt install zip g++ cmake
```

#### Arch Linux and variants

```plaintext
pacman -S zip gcc cmake
```

### Build

Clone repository and submodules:
```plaintext
git clone --recurse-submodules https://github.com/cato-a/zzz_jumpmod
```

Run build script:
```plaintext
./compile.sh json2gsc
```

If process succeeded, it should produce a new `zzz_jumpmod.pk3` for you.

**Note:** On subsequent runs, if you have not changed any of the `.json` config files in the `json2gsc/Assets` folder, you can simply run:
```plaintext
./compile.sh
```

## Jump'it Links

- [Jump'it Server](https://cod.pm/server/78.46.106.94/28961)
- [Jump'it Bounce](https://cod.pm/server/78.46.106.94/28963)
- [Jump'it Maps](https://cod.pm/jumpit)
- [Jump'it Discord](https://discord.gg/4FbaBhB)