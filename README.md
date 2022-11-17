https://devblogs.microsoft.com/cppblog/registries-bring-your-own-libraries-to-vcpkg/

---

# Registries: Bring your own libraries to vcpkg

## Can vcpkg work with non-open-source dependencies?

Yes! Up until now, your best options included hacking up overlay ports or forking the vcpkg ports tree. But there was room for improvement. Now, we are happy to announce a feature with an experience to manage any libraries you want, whether they are internal-only, open source, your own forks of open source projects, and more. In this blog post, we will delve into **registries**, our new experimental feature. We would love for you to try this feature out, give us feedback, and help us make it the best feature it can be!

## Getting started with registries

So, we’ve discussed the why of registries; now let’s discuss the how. Let’s say we are developers at North Wind Traders, and our company has a GitHub Enterprise subscription. Of course, depending on your company’s or even your personal situation, you can use whatever solution you’re already using. The goal in this blog post is to set up a git registry, the most common type of registry.

### 1. Create a new registry

The company’s GitHub organization is at https://github.com/northwindtraders, and that can be used to set up the registry. We will create our registry at https://github.com/northwindtraders/vcpkg-registry, since that’s as good a name as any, and you can follow along with the branches there.

Once we’ve created this registry, we’ll have to do a few things to actually set it up to contain the packages we want, in this case our internal JSON and Unicode libraries.

  * First, we’ll set up an empty baseline, the minimum requirement for a registry.
  * Then, we’ll add the files that our library needs to build, and make sure that they work.
  * Finally, we’ll add the library to the registry, by adding it to the versions database and writing down where to find the library in the git repository.

### 2. Create an empty registry baseline

So, let’s start. Clone the (empty) repository, and add a `baseline.json` file underneath the top level `versions` directory, containing just the following:

```
{
"default": {}
}
```

### 3. Create a vcpkg port for your library

Now, let’s set up a port entry for the first of our two libraries, the Unicode library [beicode](https://github.com/northwindtraders/beicode). If you have ever written a port, you know how to do this, but for those of us who haven’t, let’s go through it all the same.

We first create a folder for the ports to live; following the standard of the vcpkg central registry, we’ll call the folder ports. Since we use a stable git identifier to specify the directory, we don’t need to put it in a specific place, but it’s good to follow idioms. Inside this ports directory, create beicode’s port directory; inside there, place two empty files, `portfile.cmake` and `vcpkg.json`.

At this point, the registry directory should look something like this:

```
ports/
    beicode/
        portfile.cmake
        vcpkg.json
versions/
    baseline.json
```

Now, let’s fill out the port. First, since the beicode GitHub repository already has a `vcpkg.json` manifest, copy that into the `vcpkg.json` file you created:

```
{
  "name": "beicode",
  "version": "1.0.0",
  "description": "A simple utf-8 based unicode decoding and encoding library",
  "homepage": "https://github.com/northwindtraders/beicode"
}
```

### 4. Test your new vcpkg port using overlays

Let’s make sure this works by trying to install the port; we’re not using registries yet, just the pre-existing overlay-ports feature to test stuff out:

```
> vcpkg install beicode --overlay-ports=vcpkg-registry/ports/beicode
```

We should get an error: `"The folder /include is empty or not present"`. Since we aren’t doing anything just yet, that makes sense. So, let’s fill out our port! Since our port is a simple CMake library, we can create a very simple `portfile.cmake`:

```
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO northwindtraders/beicode
  REF 19a1f95c2f56a27ced90227b5e2754a602a08e69
  SHA512 7b2bb7acb2a8ff07bff59cfa27247a7b2cced03828919cd65cc0c8cf1f724f5f1e947ed6992dcdbc913fb470694a52613d1861eaaadbf8903e94eb9cdfe4d000
  HEAD_REF main
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
```
  
If we run

```
> vcpkg install beicode --overlay-ports=vcpkg-registry/ports/beicode
```

again, we’ll see that it successfully installed! We have written our first port for the registry, and now all that there’s left to do is to add the port to the version set in the registry.

### 5. Specify each version of your library in the registry

Every port’s version data lives in its own file: `versions/[first character]-/[portname].json`. For example, the version data for fmt would live in `versions/f-/fmt.json`; the version data for `zlib` would live in `versions/z-/zlib.json`. So, for `beicode`, create `versions/b-/beicode.json`:

```
{
  "versions": [
    {
      "version": "1.0.0",
      "git-tree": ""
    }
  ]
}
```
And add the following to `versions/baseline.json`:

```
{
  "default": {
    "beicode": { "baseline": "1.0.0", "port-version": 0 }
  }
}
```

Finally, let’s figure out what to put in that `"git-tree"` field. Do a git commit of the beicode port tree (but do not push), to make sure git knows about it:

```
> git add ports/beicode`
> git commit -m "[beicode] new port"
```
Then get the tree identifier for that directory:

```
> git rev-parse HEAD:ports/beicode
```

You should get something like `7fb5482270b093d40ab8ac31db89da4f880f01ba`; put that in for the `"git-tree"` in `beicode.json`, and commit the new files:

```
> git add versions
> git commit --amend --no-edit
```

And we should be done! The reason we have to do this slightly complex dance is so that we can grab exactly the files of the version we want; other versions will exist in the history of the repository, and thus are always there to be checked out.

### 6. Consume libraries from your vcpkg registry in a C++ project

Once we’ve done this, let’s try to consume the library from the new registry in an example codebase. Create a directory outside of the registry and change into that directory. Create a `vcpkg.json` which depends on beicode:

```
{
"name": "test",
"version": "0",
"dependencies": [
  "fmt",
  "beicode"
]
}
```

And a `vcpkg-configuration.json` that sets up the registry as a git registry:

```
{
  "registries": [
    {
      "kind": "git",
      "repository": "[full path to]/vcpkg-registry",
      "packages": [ "beicode", "beison" ]
    }
  ]
}
```

And try a vcpkg install:

```
> vcpkg install --feature-flags=registries,manifests
```

If it works, then you’re ready to push the registry upstream! You can try again with the actual remote registry by replacing the `"repository"` field in your `vcpkg-configuration.json` file with the actual upstream repository URL.

## How vcpkg resolves libraries from registries

You’ll notice that beicode and beison are taken from the registry we created; this is because we’ve explicitly said in `vcpkg-configuration.json` that this is where they’re from. Since we haven’t said where fmt should come from, it just comes from the default registry, which is in this case the registry that ships with vcpkg itself. Registries are never transitive; if you left off beicode from the registry in `vcpkg-configuration.json`, this would fail to work since beicode doesn’t exist in the default registry, and that’s where vcpkg will look for it. If you wanted to override fmt with your own copy, you could add it to the registry, and then add it to the packages field.

Packaging beison will be much the same, just with a different name. You can try it out for yourself, and then see if your code is any different from the [upstream](https://github.com/northwindtraders/vcpkg-registry).