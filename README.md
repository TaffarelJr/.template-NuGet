# NuGet Template Repository <!-- omit from toc -->

[![Continuous Integration](https://github.com/TaffarelJr/.template-NuGet/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/TaffarelJr/.template-NuGet/actions/workflows/continuous-integration.yml)
[![Codecov](https://codecov.io/gh/TaffarelJr/.template-NuGet/graph/badge.svg)](https://codecov.io/gh/TaffarelJr/.template-NuGet)

This is a template repo that contains the default configuration
for building and publishing a single NuGet package.

```mermaid
---
title: Personal GitHub Repo Structure
---

flowchart TB

  subgraph subGH [" "]
    gh(**.github**
    repo)

    noteGH[This contains core files
    to be referenced by
    or synced to other repos.]
  end

  subgraph subT [" "]
    T1(**.template-&lt;type&gt;**
    repo)

    T2(**.template-&lt;type&gt;**
    repo)

    noteT[These define more specific
    default files and structures
    for different repo types.]
  end

  subgraph subR [" "]
    R1(**&lt;name&gt;**
    repo)

    R2(**&lt;name&gt;**
    repo)

    R3(**&lt;name&gt;**
    repo)

    R4(**&lt;name&gt;**
    repo)

    noteR[These are the actual repos
    where projects live.]
  end

  classDef current fill:#E68A39,color:#000000
  class T1,T2 current

  classDef sub opacity:0
  class subGH,subT,subR sub

  classDef note fill:#FFFFDD,color:#000000
  class noteGH,noteT,noteR note

  gh --> T1
  gh --> T2

  T1 --> R1
  T1 --> R2
  T2 --> R3
  T2 --> R4
```

#### Table of Contents <!-- omit from toc -->

- [Description of Files in This Template Repo](#description-of-files-in-this-template-repo)
  - [Community Health](#community-health)
  - [GitHub Configuration](#github-configuration)
  - [GitHub Workflows](#github-workflows)
  - [.NET Configuration](#net-configuration)
  - [.NET Placeholder Solution](#net-placeholder-solution)
  - [Build Scripts](#build-scripts)
  - [Other Files](#other-files)

## Description of Files in This Template Repo

GitHub allows some community health and GitHub configuration files
to only reside in the .github repo
and automatically appear in all other repos.
However, we can't take full advantage of that feature
because most files need repo-specific customization.

### [Community Health][ghComHealth]

| File                                | Exists only in</br>.github repo | Overridden in<br/>template repo | Notes                    |
| :---------------------------------- | :-----------------------------: | :-----------------------------: | :----------------------- |
| 📁[.github/][githubFolder]          |                                 |                                 |                          |
| &nbsp;├─📄[CODEOWNERS][codeOwnFile] |               N/A               |               ✅                |                          |
| &nbsp;└─📄FUNDING.yml               |               ✅                |                                 |                          |
| 📄[CODE_OF_CONDUCT.md][cocFile]     |                                 |               ✅                | Linked to by other files |
| 📄[CONTRIBUTING.md][contribFile]    |                                 |               ✅                | Links to other files     |
| 📄GOVERNANCE.md                     |                —                |                —                | Not implemented          |
| 📄[LICENSE][licenseFile]            |               N/A               |               ✅                |                          |
| 📄[SECURITY.md][securityFile]       |                                 |               ✅                | Links to GitHub repo     |
| 📄[SUPPORT.md][supportFile]         |                                 |               ✅                | Links to other files     |

### [GitHub Configuration][ghTemplates]

| Template                                             | Exists only in</br>.github repo | Overridden in<br/>template repo | Description                                     |
| :--------------------------------------------------- | :-----------------------------: | :-----------------------------: | :---------------------------------------------- |
| 📁[.github/][githubFolder]                           |                                 |                                 |                                                 |
| &nbsp;├─📁DISCUSSION_TEMPLATE/                       |                —                |                —                | Not implemented                                 |
| &nbsp;├─📁[ISSUE_TEMPLATE/][issueFormsFolder]        |                                 |               ✅                | Contains [GitHub Issue forms][ghIssueForms]     |
| &nbsp;│&nbsp;&nbsp;&nbsp;&nbsp;└─📄config.yml        |               ✅                |                                 | [GitHub Issue template chooser][ghIssueChooser] |
| &nbsp;├─📄[codecov.yml][codecovFile]                 |               N/A               |               ✅                | [Codecov configuration][codecov]                |
| &nbsp;├─📄[copilot-instructions.md][copilotFile]     |               N/A               |               ✅                | [Copilot configuration][ghCopilot]              |
| &nbsp;├─📄[dependabot.yml][dependabotFile]           |               N/A               |               ✅                | [Dependabot configuration][ghDependabot]        |
| &nbsp;├─📄[pull_request_template.md][prTemplateFile] |                                 |               ✅                | [GitHub Pull Request template][ghPRTemplate]    |
| &nbsp;└─📄[settings.yml][settingsFile]               |               N/A               |               ✅                | [Repo configuration][ghSettings]                |

### [GitHub Workflows][ghWorkflows]

| Workflow                                                                           | Description                                               |
| :--------------------------------------------------------------------------------- | :-------------------------------------------------------- |
| 📁[.github/][githubFolder]                                                         |                                                           |
| &nbsp;└─📁[workflows/][workflowFolder]                                             |                                                           |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├─📄[Continuous Integration][ciWorkflow] | Builds, tests, and packs the solution.                    |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├─📄[Create Release][releaseWorkflow]    | Creates draft Releases in GitHub                          |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├─📄[Template Sync][syncWorkflow]        | Synchronizes files from a template repo to a derived repo |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─📄[Validate Codecov][codecovWorkflow]  | Validates changes to [codecov.yml][codecovFile]           |

### .NET Configuration

| File                              | Description                       |
| :-------------------------------- | :-------------------------------- |
| 📁[.config/][configFolder]        | Contains `dotnet` tool settings   |
| 📄[.vsconfig][vsConfigFile]       | Visual Studio settings            |
| 📄[global.json][globalJsonFile]   | .NET SDK settings                 |
| 📄[nuget.config][nugetConfigFile] | NuGet settings                    |
| 📄[StyleCop.json][styleCopFile]   | StyleCop (code analysis) settings |

### .NET Placeholder Solution

| File                                              | Description                                 |
| :------------------------------------------------ | :------------------------------------------ |
| 📁[src/][srcFolder]                               | Contains production code                    |
| &nbsp;└─📄[Production.props][prodPropsFile]       | .NET project properties for production code |
| 📁[test/][testFolder]                             | Contains test code                          |
| &nbsp;├─📄[.editorconfig][testEditorConfigFile]   | Code analysis exceptions for test code      |
| &nbsp;├─📄[Test.props][testPropsFile]             | .NET project properties for test code       |
| &nbsp;└─📄[Test.runsettings][testRunsettingsFile] | .NET test run settings                      |
| 📄[Common.props][commonPropsFile]                 | .NET project properties for all code        |
| 📄[Icon.png][iconFile]                            | NuGet package icon                          |
| 📄[Icon.svg][iconSourceFile]                      | NuGet package icon source                   |
| 📄[Placeholder.sln][solutionFile]                 | Visual Studio solution                      |

### Build Scripts

| File                       | Description                           |
| :------------------------- | :------------------------------------ |
| 📄[Build.ps1][buildPsFile] | Full build script (PowerShell)        |
| 📄[build.sh][buildShFile]  | Full build script (bash)              |
| 📄[Test.ps1][testPsFile]   | Full build & test script (PowerShell) |
| 📄[Test.sh][testShFile]    | Full build & test script (bash)       |

### Other Files

| File                                         | Description                                             |
| :------------------------------------------- | :------------------------------------------------------ |
| 📁[.vscode/][vsCodeFolder]                   | Contains VSCode settings                                |
| 📁[docs/][docsFolder]                        | Contains documentation                                  |
| 📁[test/][testFolder]                        | Contains test code                                      |
| &nbsp;└─📄[TestHelpers.psm1][testHelperFile] | Helper methods for [Continuous Integration][ciWorkflow] |
| 📄[\_checklist.md][checklistFile]            | New template repo checklist                             |
| 📄[.editorconfig][editorConfigFile]          | [Styleguide rule definitions][styleguideFile]           |
| 📄[.gitattributes][gitAttributesFile]        | Built using [scaffolding][ghGitAttributes]              |
| 📄[.gitignore][gitIgnoreFile]                | Built using [scaffolding][ghGitIgnore]                  |
| 📄[.gitmessage][gitMessageFile]              | [Commit message template][styleguideFile-commit]        |
| 📄[GenerateChangelog.ps1][changelogFile]     | Script for generating the release changelog             |
| 📄[GitVersion.yml][gitVersionFile]           | [GitVersion configuration][gitVersion]                  |

<!-- Source Code URIs (alphabetical by file hierarchy) -->

[githubFolder]: ./.github/
[issueFormsFolder]: ./.github/ISSUE_TEMPLATE/
[workflowFolder]: ./.github/workflows/
[ciWorkflow]: ./.github/workflows/continuous-integration.yml
[releaseWorkflow]: ./.github/workflows/create-release.yml
[syncWorkflow]: ./.github/workflows/template-sync.yml
[codecovWorkflow]: ./.github/workflows/validate-codecov.yml
[codecovFile]: ./.github/codecov.yml
[codeOwnFile]: ./.github/CODEOWNERS
[copilotFile]: ./.github/copilot-instructions.md
[dependabotFile]: ./.github/dependabot.yml
[prTemplateFile]: ./.github/pull_request_template.md
[settingsFile]: ./.github/settings.yml
[configFolder]: ./.config/
[vsCodeFolder]: ./.vscode/
[docsFolder]: ./docs/
[styleguideFile]: ./docs/Styleguide.md
[styleguideFile-commit]: ./docs/Styleguide.md#commit-messages
[srcFolder]: ./src/
[prodPropsFile]: ./src/Production.props
[testFolder]: ./test/
[testEditorConfigFile]: ./test/.editorconfig
[testPropsFile]: ./test/Test.props
[testRunsettingsFile]: ./test/Test.runsettings
[testHelperFile]: ./test/TestHelpers.psm1
[checklistFile]: ./_checklist.md
[editorConfigFile]: ./.editorconfig
[gitAttributesFile]: ./.gitattributes
[gitIgnoreFile]: ./.gitignore
[gitMessageFile]: ./.gitmessage
[vsConfigFile]: ./.vsconfig
[buildPsFile]: ./Build.ps1
[buildShFile]: ./build.sh
[cocFile]: ./CODE_OF_CONDUCT.md
[commonPropsFile]: ./Common.props
[contribFile]: ./CONTRIBUTING.md
[changelogFile]: ./GenerateChangelog.ps1
[gitVersionFile]: ./GitVersion.yml
[globalJsonFile]: ./global.json
[iconFile]: ./Icon.png
[iconSourceFile]: ./Icon.svg
[licenseFile]: ./LICENSE
[nugetConfigFile]: ./nuget.config
[solutionFile]: ./Placeholder.sln
[securityFile]: ./SECURITY.md
[styleCopFile]: ./StyleCop.json
[supportFile]: ./SUPPORT.md
[testPsFile]: ./Test.ps1
[testShFile]: ./test.sh

<!-- GitHub Repo URIs (alphabetical by name) -->

[ghGitAttributes]: https://github.com/gitattributes/gitattributes
[ghGitIgnore]: https://github.com/github/gitignore
[ghSettings]: https://github.com/repository-settings/app

<!-- Public URIs (alphabetical by name) -->

[codecov]: https://docs.codecov.com/docs/codecov-yaml
[freeCodeCamp]: https://www.freecodecamp.org/news/how-to-use-the-dot-github-repository
[ghComHealth]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file
[ghCopilot]: https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot
[ghDependabot]: https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference
[ghIssueChooser]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#configuring-the-template-chooser
[ghIssueForms]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/manually-creating-a-single-issue-template-for-your-repositoryhttps://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms
[ghPRTemplate]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository
[ghTemplates]: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository
[ghWorkflows]: https://docs.github.com/en/actions/how-tos/writing-workflows
[gitVersion]: https://gitversion.net/docs/reference/configuration
