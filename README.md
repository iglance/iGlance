# iGlance &ensp;&ensp;[![Build Status](https://travis-ci.org/iglance/iGlance.svg?branch=master)](https://travis-ci.org/iglance/iGlance) [![Github All Releases](https://img.shields.io/github/downloads/iglance/iGlance/latest/total.svg?colorB=orange)](https://github.com/iglance/iGlance/releases) [![SwiftLint Sindre](https://img.shields.io/badge/SwiftLint-Sindre-hotpink.svg)](https://github.com/sindresorhus/swiftlint-sindre)
> Free and open source system monitor for OSX and macOS for the menu bar

## Introduction

iGlance is a small system monitor that displays current stats about your Mac on the menu bar. It is built to be highly customizable so that everyone can adjust it to his/her needs. A full list of all the features is below. If you encounter any bugs or have suggestions for new features, feel free to write them down in the Issues tab.

<img src="readme_images/Menubar_Preview.png" title="Menubar Preview" alt="Menubar Preview" width="400"/>
<img src="readme_images/iGlance_Preview.png" title="iGlance Preview" alt="iGlance Preview"/>

## Features

-   Display CPU utilization as a graph
-   Read CPU temperature
-   Monitor memory usage
-   Monitor network usage
-   Monitor fan speed
-   Low and/or high battery notification at custom thresholds
-   App adjusts to light & dark mode

## Installation

There are two possible ways to install iGlance: 

1. Download the iGlance.dmg from https://github.com/iglance/iGlance/releases and manually move the app into the applications folder.
2. Install iGlance using [brew](https://brew.sh):

    `brew cask install iglance`

## Contribute

There are two ways you can contribute to this project:

1. You can star this repository and tell all your friends about our cool app ;)
2. You can work on one of the open issues. Please read our [Contribution Guide](https://github.com/iglance/iGlance/blob/master/.github/CONTRIBUTING.md) and our [Code of Conduct](https://github.com/iglance/iGlance/blob/master/.github/CODE_OF_CONDUCT.md) before you start.

## Credits
- <a href="https://github.com/beltex">beltex</a> for providing the SMCKit and SystemKit Library
- <a href="https://github.com/CocoaLumberjack/CocoaLumberjack">CocoaLumberjack</a> for their awesome logging framework
- <a href="https://github.com/OskarGroth">Oskar Groth</a> for providing his AppMover framework
- And of course all the other <a href="https://github.com/iglance/iGlance/graphs/contributors">contributors</a>.

## License

This software is published under the <b>GNU GPLv3</b>.
