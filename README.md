---
home: https://gitlab.com/compact-for-space/site/
stable link: https://gitlab.com/projects/81882967
mirror: https://github.com/compact-for-space/site/
doi: https://doi.org/10.5281/zenodo.21478659
website: https://compact-mission.space/
---
<!--
SPDX-FileCopyrightText: 2026 COMPACT-for-space contributors

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# compact-for-space

This repository contains the source code and build instructions for
building the [COMPACT website](https://compact-mission.space/).

## Contribution

To contribute to this project,
please follow the standard software development workflow:

### Quick Start (TL;DR)

1. Fork the repository
2. Branch for your changes (recommended)
3. Create your content
4. Add yourself as contributor in `metadata.json` (in the root directory)
5. Adapt version `.metadata.version` in `metadata.json`
6. Submit a Merge Request

### Detailed Steps

#### 1. create a fork

Create a fork of this repository to your own namespace
(e.g., your personal user space).
This allows you to make changes without affecting the main project.

![fork button](images/fork-button.png)

#### 2. create a branch

![branch button](images/branch-button.png)

While you can work directly in your fork, we highly recommend creating a
separate feature branch for your specific changes.
This makes it easier to sync updates from the upstream project and
manage multiple contributions.

![new branch button](images/new-branch.png)

Alternatively, you may use a single developer branch in your fork
if you wish to reduce the total number of branches.

#### 3. implement changes

Create your content or fix the bugs.

#### 4. add yourself as contributor

Important: If you are adding a new page or significant content,
remember to add your name and details to [`metadata.json`](metadata.json)
to be credited as a contributor.

#### 5. Adapt version

Adapt version `.metadata.version` in [`metadata.json`](metadata.json) following
semantic versioning (cf. [semver.org](https://semver.org/))

Important: Ensure that the version tag (`.metadata.version`) in `metadata.json`
does not already exist in the repository.

#### 6. create a merge request

Once you have pushed your changes to your fork, open a merge request (MR)
to the `contributions` branch of the original repository
([`compact-for-space/site`](https://gitlab.com/compact-for-space/site)).

Note: Please do not request a merge into the `main` branch directly.
All contributions are first reviewed in the `contributions` branch.
Once approved, the maintainers will merge your changes into `main`.

This workflow ensures that all automated pipelines (including those with
special permission requirements) run successfully in a controlled environment
before the changes are integrated.

Please provide a clear description of the changes you have made.

![create merge request](images/create-merge-request.png)

## License

Unless otherwise noted, all content is licensed under
[CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

See [LICENSE.md](LICENSE.md) and the [LICENSES/](LICENSES/) directory
for details.
