# Creating a New NuGet Package Repo <!-- omit in toc -->

NuGet package repos use the [.template-nuget][ghTemplate] repo as their base template.
Follow these steps to create a new repo derived from it.

#### Table of Contents <!-- omit in toc -->

- [1. Create the new repo](#1-create-the-new-repo)
- [2. Configure manual repo settings](#2-configure-manual-repo-settings)
- [3. Clone the new repo](#3-clone-the-new-repo)
- [4. Customize template files](#4-customize-template-files)
- [5. Customize root files](#5-customize-root-files)
- [6. Customize repo settings](#6-customize-repo-settings)
- [7. Customize VS Solution](#7-customize-vs-solution)
- [8. Push the changes to GitHub](#8-push-the-changes-to-github)
- [9. Run the Template Sync workflow](#9-run-the-template-sync-workflow)

## 1. Create the new repo

- DO NOT use a template in GitHub when creating the new repo;
  we'll use Git merge to get the necessary files instead
- Always use kebab-case for the repo name
- Leave the description blank
- Don't add any files to the new repo; leave it empty

## 2. Configure manual repo settings

Not all repo settings can be managed from [settings.yml][settingsFile].
The following must be configured manually:

- Go to `Settings`
  - Go to `General`
    - Check `Limit how many branches and tags can be updated in a single push`
      - Up to `2` branches and tags can be updated in a push
  - Go to `Moderation options`
    - Go to `Code review limits`
      - Check `Limit to users explicitly granted read or higher access`
  - Go to `Actions`
    - Go to `General`
      - Check `Allow GitHub Actions to create and approve pull requests`
      - Click `Save`
  - Go to `Advanced Security`
    - Enable `Private vulnerability reporting`
    - Enable `Dependency graph` _(if necessary)_
    - Enable `Grouped security updates`
    - Set up `CodeQL analysis` to use `Default` settings
  - Go to `Secrets and variables`
    - Go to `Actions`
      - Add a repo secret called `CODECOV_TOKEN`
        (get the value from [Codecov][codecovToken])

## 3. Clone the new repo

Clone the new repo locally and open it in Visual Studio Code.
The .template-nuget repo needs to be added as an upstream remote
so the template sync workflow can merge its commits into the new repo.
Execute the following commands:

```bash
# May need to configure SSH key before executing this
git config remote.pushdefault origin
git remote add template git@github.com:TaffarelJr/.template-nuget.git
git fetch template
git checkout -B main template/main
git config commit.template .gitmessage
```

## 4. Customize template files

Some files that were synced from the [.template-nuget][ghTemplate] repo
need to be customized for the new repo:

- Delete the following files that will
  reside only in the [.template-nuget][ghTemplate] repo:
  - `_checklist.md`
- Find all instances of `TaffarelJr/.template-nuget` in the new repo
  - Replace with `TaffarelJr/<new repo name>` in **ONLY** these files:
    - [ISSUE_TEMPLATE/\*][issueFormsFolder]
    - [CONTRIBUTING.md][contribFile]
    - [SECURITY.md][securityFile]
    - [SUPPORT.md][supportFile]
- Find all instances of `TaffarelJr/.github` in the new repo
  - Replace with `TaffarelJr/.template-nuget` in **ONLY** these files:
    - [Template Sync][syncFile] workflow
- Make any additional changes to the template files as necessary
- Commit the changes, using the following commit message:

  ```bash
  git commit -m 'chore: customize template files'
  ```

## 5. Customize root files

Now add deeper customization to the root files
to meet the needs of the new repo:

- Add any additional ecosystems to [dependabot.yml][dependabotFile]
- Delete [\_checklist.md][checklistFile]
- Modify [.editorconfig][editorConfigFile] as needed
- Modify [.gitattributes][gitAttributesFile] as needed
  (using [scaffolding][ghGitAttributes])
- Modify [.gitignore][gitIgnoreFile] as needed
  (using [scaffolding][ghGitIgnore])
- Replace contents of [README.md][readmeFile]
- Make any additional changes to the root files as necessary
- Commit the changes, using the following commit message:

  ```bash
  git commit -m 'chore: customize root files'
  ```

## 6. Customize repo settings

Most settings in [settings.yml][settingsFile]
are fine to be inherited from the [.template-nuget][ghTemplate] repo.
Only a few need to be overridden in the new repo.

- Replace the contents of the file with the following,
  filling in the values as indicated:

  ```yml
  _extends: .template-nuget

  repository:
    #─────────────────────────────────────────────────────────────────────────────
    # "About" section (on Home Page)
    # https://github.com/repository-settings/app/blob/master/docs/plugins/repository.md
    # https://docs.github.com/en/rest/repos/repos#update-a-repository
    #─────────────────────────────────────────────────────────────────────────────

    # A short description of the repo
    # MUST BE A SINGLE LINE
    description: <1-line description>.

    # A URL with more information about the repo
    homepage: <URI, if applicable; otherwise, delete this property>

    # A comma-separated list of topics to set on the repo
    # See https://github.com/topics
    topics: <topic 1>, <topic 2>, ...

    #─────────────────────────────────────────────────────────────────────────────
    # Settings → General
    # https://github.com/repository-settings/app/blob/master/docs/plugins/repository.md
    # https://docs.github.com/en/rest/repos/repos#update-a-repository
    #─────────────────────────────────────────────────────────────────────────────

    # The name of the repo
    name: <name>

    # Whether the repo is available as a template
    is_template: false

    # Whether to allow merging pull requests with a merge commit
    allow_merge_commit: true

    # Whether to allow rebase-merging pull requests
    allow_rebase_merge: false
  ```

- Make any additional changes as needed
- Commit the changes, using the following commit message:

  ```bash
  git commit -m 'chore: customize repo settings'
  ```

## 7. Customize VS Solution

- Find all instances of `Placeholder` in the new repo
  - Replace with `<NuGet package name>` in **ONLY** these files:
    - [Placeholder.sln][solutionFile]
    - Project files under [src/][srcFolder]
    - Project files under [test/][testFolder]
- Find all folders and files named `Placeholder` in the new repo
  - Rename with `<NuGet package name>`:
    - [Placeholder.sln][solutionFile]
    - Project folders and files under [src/][srcFolder]
    - Project folders and files under [test/][testFolder]
- Delete all content from [PublicAPI.Unshipped.txt][unshippedApiFile]
- Delete temporary classes in all projects
- Update [Icon.svg][iconSourceFile] with a new image
  - Good source: https://www.iconfinder.com/
  - Format the SVG code for human-readability
- Overwrite [Icon.png][iconFile] with new export from SVG
  - Should be 128x128, transparent background
- Add additional projects if necessary
- Validate project dependencies
- Update NuGet dependencies
- Make sure the solution builds successfully
- Make sure all tests pass
- Make sure there are no warnings or messages
- Commit the changes, using the following commit message:

  ```bash
  git commit -m 'chore: customize VS solution'
  ```

## 8. Push the changes to GitHub

Push the branch to GitHub:

```bash
git push
```

The settings should take effect almost immediately.
Verify that the new repo description and topics appear on the home page.

## 9. Run the [Template Sync][syncFile] workflow

Finally, validate the template sync workflow:

- Go to `Actions` → `Template Sync`
  - Click `Run workflow`
  - Make sure `main` is selected
  - Click `Run workflow`

The process should complete with no changes,
and without creating a Pull Request.

<!-- Source Code URIs (alphabetical by file hierarchy) -->

[issueFormsFolder]: ./.github/ISSUE_TEMPLATE/
[syncFile]: ./.github/workflows/template-sync.yml
[dependabotFile]: ./.github/dependabot.yml
[settingsFile]: ./.github/settings.yml
[srcFolder]: ./src/
[unshippedApiFile]: ./src/Placeholder/PublicAPI.Unshipped.txt
[testFolder]: ./test/
[checklistFile]: ./_checklist.md
[editorConfigFile]: ./.editorconfig
[gitAttributesFile]: ./.gitattributes
[gitIgnoreFile]: ./.gitignore
[contribFile]: ./CONTRIBUTING.md
[iconFile]: ./Icon.png
[iconSourceFile]: ./Icon.svg
[solutionFile]: ./Placeholder.sln
[readmeFile]: ./README.md
[securityFile]: ./SECURITY.md
[supportFile]: ./SUPPORT.md

<!-- GitHub Repo URIs (alphabetical by name) -->

[ghGitAttributes]: https://github.com/gitattributes/gitattributes
[ghGitIgnore]: https://github.com/github/gitignore
[ghTemplate]: https://github.com/TaffarelJr/.github

<!-- Public URIs (alphabetical by name) -->

[codecovToken]: https://app.codecov.io/account/gh/TaffarelJr/org-upload-token
