# Creating a New NuGet Package Repo <!-- omit in toc -->

NuGet package repos use the [`.template-NuGet`][template] repo
as their base template.
Follow these steps to create a new repo derived from it.

#### Table of Contents <!-- omit in toc -->

- [1. Create the new template repo](#1-create-the-new-template-repo)
- [2. Configure manual repo settings](#2-configure-manual-repo-settings)
- [3. Clone the repo](#3-clone-the-repo)
- [4. Customize template files](#4-customize-template-files)
- [5. Customize root repo files](#5-customize-root-repo-files)
- [6. Override repo settings](#6-override-repo-settings)
- [7. Push the changes to GitHub](#7-push-the-changes-to-github)
- [8. Run the template sync](#8-run-the-template-sync)

## 1. Create the new template repo

- DO NOT use a template in GitHub when creating the repo;
  we'll implement Git merges to get the files instead.
- Leave the description blank.
- Don't add any files to the repo, leave it empty.

## 2. Configure manual repo settings

Not all repo settings can be managed from the `settings.yml` file.
The following settings must be configured manually:

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
  - Go to `Code security`
    - Enable `Private vulnerability reporting`
    - Enable `Dependency graph` _(if necessary)_
    - Enable `Grouped security updates`
    - Set up `CodeQL analysis` to use `Default` settings

## 3. Clone the repo

Clone the repo locally and open it in Visual Studio Code.
The [`.template-NuGet`][template] repo needs to be added as an upstream remote
so the template sync can import the commits to the new repo
with those in the [`.template-NuGet`][template] repo.
Execute the following commands:

```bash
# May need to configure SSH key
git config remote.pushdefault origin
git remote add template git@github.com:TaffarelJr/.template-NuGet.git
git fetch template
git checkout -B main template/main
git config commit.template .gitmessage
```

## 4. Customize template files

Some files that were synced from the [`.template-NuGet`][template] repo
need to be customized for this new repo.

- Delete the following files that will
  reside only in the [`.template-NuGet`][template] repo:
  - `_Checklist.md`
- Find all instances of `TaffarelJr/.template-NuGet` in the repo
  - Replace it with `TaffarelJr/<new repo name>` in **ONLY** these files:
    - `CONTRIBUTING.md`
    - `SECURITY.md`
    - `SUPPORT.md`
    - `/ISSUE_TEMPLATE/01_bug_report.yml`
    - `/ISSUE_TEMPLATE/02_performance_issue.yml`
    - `/ISSUE_TEMPLATE/03_feature_request.yml`
- Commit the changes with the message: `chore: customize template files`

## 5. Customize root repo files

Now we can add deeper customization to the root repo files
to meet the needs of the new repo:

- Replace the contents of the `README.md` file
- Add any additional ecosystems to `dependabot.yml`
- Add a package icon as `Icon.png`
- Add any additional root files necessary for the new template
- Commit the changes with the message: `chore: customize root repo files`

## 6. Override repo settings

Most of the settings in the `settings.yml` file
are appropriate to inherit from the [`.template-NuGet`][template] repo.
Only a few of them need to be overridden in the new template repo.

Replace the contents of the file with the following,
filling in the values as indicated:

```yaml
_extends: .template-NuGet

repository:

  #─────────────────────────────────────────────────────────────────────────────
  # "About" section (on Home Page)
  #─────────────────────────────────────────────────────────────────────────────

  # A short description of the repo
  # MUST BE A SINGLE LINE
  description: <1-line description>.

  # A URL with more information about the repo
  homepage: <URI, if applicable; otherwise, delete this property>

  #─────────────────────────────────────────────────────────────────────────────
  # Settings → General
  # https://github.com/repository-settings/app/blob/master/docs/plugins/repository.md
  # https://docs.github.com/en/rest/repos/repos#update-a-repository
  #─────────────────────────────────────────────────────────────────────────────

  # The name of the repo
  name: <name>
```

Make any additional changes as needed.
Commit the changes with the message: `chore: customize repo settings`

## 7. Push the changes to GitHub

Push the branch to GitHub:

```bash
git push
```

The settings should take effect almost immediately;
verify that the repo description and tags appear on the home page.

## 8. Run the template sync

Finally, validate the template sync.
To do this, go to `Actions` → `Template Sync` → `Run workflow` → `main`
and click `Run workflow`. The process should complete with no changes.

<!-- GitHub repo URIs -->

[template]: https://github.com/TaffarelJr/.template-NuGet
