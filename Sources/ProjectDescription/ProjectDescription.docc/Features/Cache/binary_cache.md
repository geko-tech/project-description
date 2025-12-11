# Binary module cache

@Metadata {
    @PageKind(article)
}

## Overview

Geko provides a powerful way for everyone to speed up project builds by caching your modules as binaries (`.frameworks` and `.xcframeworks`) and sharing them accross your team and different envrionments. This feature allows you to use previously built binaries, reduces the need for recompilation, and significantly speeds up the build process. This feature allows you to use the cache both locally and remote cache. We provide ability to independently configure a remote cache using S3 technology.

Geko, as part of the project generation command, does everything necessary to ensure you can build your project with a warmed-up cache and work only with the modules you prefer. Geko's main actions include:

* Geko load a project graph and calculate unique hashes for the current project revision.
* Geko check the local and remote cache for available binary modules that match the hash.
* If no binary modules are found, Geko will pre-generate the project and warmup the missing modules.
* Than traverse the graph and replace all required source modules with pre-built ones.
* After all geko generate the project and open it with Xcode.

### Modules Hashing

To distinguish modules built from different commits, Geko hashes module information, including their source files, dependencies, and many other parameters. It is very important that all modules are up-to-date when the project is generated. This means that if your modules have any build phase scripts that affect the final project state, they must be executed before calculating the hashes. For example, suppose you use swiftgen to generate access to your static resources. If you don't generate the files before modules hahsing, it may affect the cache hit.

Geko allows you to list the names of build phase scripts that must be run before calculating the hashes. To do this, define the ``Cache/Profile/scripts`` array when declaring the ``Cache/Profile``. Geko will then execute these scripts before calculating the hashes.

### Supported products 

Only the following target products are cacheable by Geko: 

* Frameworks (static and dynamic). They may depend on xctest
* Bundles 

> Upstream dependencies: When a target is non-cacheable it makes the upstream targets non-cacheable too. For example, if you have the dependency graph `A > B`, where A depends on B, if B is non-cacheable, A will also be non-cacheable.

### Efficiency 

The efficiency of Geko cache depends directly on your approach to project architecture and the structure of your modules graph. Here are a few points to consider:
* You should use a modular architecture.
* The smaller the graph depth and the less coupling between modules, the better the cache will work.
* Split frequently modified modules into several smaller ones to reduce the frequency of their recompilation.
* Define dependencies with protocol/interface targets instead of implementation ones, and dependency-inject implementations from the top-most targets.

## Setup 

### Local Cache 

Geko uses a profile-based approach to warming up your project. Profiles allow Geko to know which configurations and targets to warm up the cache with. By default, there are two profiles: `Debug` and `Release`, which build the cache for iOS and the ARM architecture. To start using the cache locally in its basic configuration, you don't need to do anything extra. To get started, you can use one of the following commands:

```bash
geko generate --cache # All cachable modules will be cached 
geko generate App Auth --cache # Cache with focus on module App and Auth. All other modules will be pruned or cached
geko generate App Auth --cache --profile MyCustomProfile # Geko will use MyCustomProfile to warmup the cache
```

#### Profiles 

You can create multiple ``Cache/Profile`` so that Geko knows which configurations and targets to use for cache warmup. To do this, you need to define all the parameters required for your build in the `Config.swift` manifest.

```swift
let config = Config(
    cache: .cache(
        profiles: [
            .profile(
                name: "Default", // Custom profile name. You can override Default profile with the same name and don't need to specify it in the command line
                configuration: "Debug", // Configuration to use for cache warmup
                platforms: [
                    .iOS: .options(arch: .arm64, os: "26.0", device: "iPhone 11") // Platforms and options to use for cache warmup
                ],
                scripts: [
                    .script(name: "SwiftGen", envKeys: ["SRCROOT"]) // List of build phase scripts to run before hashing
                ],
                options: .options() // Additional options for cache warmup
            )
        ]
    )
)
```

> Note: Geko supports building caches for multiple platforms simultaneously. In this case, you'll use xcframeworks instead of frameworks. However, using multiple platforms can significantly impact warm-up time. Therefore, we recommend separating different platforms into different profiles.

### Remote Cache 

Geko makes it very easy to set up your own remote cache. To do this, you need to set up your own S3 server using AWS or use any other S3 API-compatible service.

TODO: Auth for download not ready now. 

Once you have configured your S3, you need to specify information about it in your `Config.swift` file with ``Config/cloud``.

```swift 
let confisg = Config(
    cloud: .cloud(
        bucket: "my-bucket-name",
        url: "my-url-to-s3"
    )
)
```

After this, Geko will start accessing your S3 server to download the pre-built modules when generating a project. If a module isn't found in S3, Geko will warm it up and save it only in the local cache.

To upload locally built modules to the remote cache, use the command:

```bash 
geko cache upload 
``` 

Before upload you should declare ENV variables to access your s3 storage:

```bash
export GEKO_CLOUD_ACCESS_KEY="your_access_key"
export GEKO_CLOUD_SECRET_KEY="your_secret_key"
```

After each `geko generate --cache` command, the `.geko/Cache/BuildCache/latest_build` file is created, which contains information about the last warmup of the local cache. Using this file, the `upload` command determines which modules need to be loaded into the remote cache. This file is overwritten after each warmup.

## Topics

- <doc:cache_usage>
- <doc:cache_debug>
