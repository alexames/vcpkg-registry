# Simple vcpkger examples

## Create a new port
```
python vcpkger.py create imgui-file-dialog `
  --github-repo 'aiekick/ImGuiFileDialog' `
  --commit-hash c989ceffa3bc3bb4652357a947fb77325e5df4c9 `
  --version '1.88' `
  --branch master
```

## Update an existing port
```
python vcpkger.py update luawrapper `
  --github-repo 'alexames/luawrapper' `
  --commit-hash aa23890767290ac3bddd563e847e65c0a27fcb33 `
  --version '0.0.4' `
  --branch experimental
```

## List current ports in the `vcpkg-configuration.json` format.
```
python vcpkger.py list
```