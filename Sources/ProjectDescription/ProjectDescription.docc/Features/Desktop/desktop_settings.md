# Project Configuration

@Metadata {
    @PageKind(article)
}

## Project Settings

> A configuration is the current set of settings and a list of focus modules with which the project will be built. You can create multiple configurations to suit different needs. For example, you might want to build the project entirely from source code or focus on a few modules.

Example of adding a configuration

![inspector](desktop_conf_conf)

![inspector](desktop_conf_edit)

# Other settings

## Profile

The profile used in geko generate. Learn more about Profiles TODO: - Link to profiles

![inspector](desktop_conf_profile)

## Scheme

Project scheme name [Learn more about a project schemes](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project)

![inspector](desktop_conf_scheme)

## Options

Geko options. Also you can add/edit/remove castom options. [Learn about default geko options](<doc:cache_usage>)

![inspector](desktop_conf_options)

![inspector](desktop_conf_options_edit)

## Destination

Destination device or simulator

![inspector](desktop_conf_target)

## Focus modules

The list of modules that will remain in focus. Focused modules are modules, that will not be cached and will remain as sources. Clicking the edit button will open a dialog popup for adding or removing modules from the cache.

![inspector](desktop_conf_focus_edit)

![inspector](desktop_conf_focus_empty)

## Final build command

The final command that is called in the console. Can be copied to the clipboard.

![inspector](desktop_conf_command)