# How to Contribute

<b>First of all thanks for taking the time and wanting to contribute to this project 👍🏼🎉</b>

## How can I start coding?

Before you start coding it is best to directly comment on the issue and tell everyone that you want to work on it. This prevents misunderstandings such that two persons start working on the same issue. We will then assign the issue to you as soon as possible.

Now that everyone knows that you wanna work on this issue you can start by forking the repository. This will create a copy of the repository on your GitHub account. After forking the repository you can clone it using the following command (be sure to use SSH). More info on how to clone a repository using SSH can be found [here](https://help.github.com/en/github/using-git/which-remote-url-should-i-use#cloning-with-ssh-urls):

```
git clone --recurse-submodules git@github.com:iglance/iGlance.git
```

## Installing the dependencies

After cloning your forked repository you have to install the dependencies of the project using [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). To install the dependencies using both dependency managers you can execute the following command (including the parantheses) in the root directory of the cloned repository:

```
(cd ./iGlance && pod install && cd ./iGlance && carthage update)
```

If you get an error during building the carthage libraries [this](https://stackoverflow.com/questions/40743713/command-line-tool-error-xcrun-error-unable-to-find-utility-xcodebuild-n) might help you.

## Getting ready for development

We have a `master` and a `development` branch in this repository. The `master` branch is responsible for all the releases. We push to this branch only if we release a new version. The development (as the name suggests) is for developing.
Therefore the next step is to create a new branch which is based on the `development` branch. To make it clear which issue is referenced by this branch your branch should be named after the following scheme:

`feature/<github_issue-id>-<issue_name>`  
`bug-fix/<github_issue_id>-<issue_name>`

Now you can start coding 🎉💻🖥

## Merging your code

After you finished implementing the feature you can create a new pull request.
Please create a pull request that will merge the changes on your `feature branch` into the `development` branch in the main repository. [Here](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) you can find more info on how to create a pull request from your branch.
