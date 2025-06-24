# Git Worktree
# Manage multiple working trees attached to the same repository.

#### A git repository can support multiple working trees, allowing you to check out more than one branch at a time.
#### Essentially it allows to work with different workspaces on different Intellij IDEA windows simultaneously, like cloning the repository multiple times but faster and without the storage impact.
#### For more info run: `git help worktree`

-----------------------------------------------------------------------------------------------------------------------------------

## GWT Script

#### Introducing `gwt` script for git worktree. 
#### Automates the process when adding/removing branches.

### Installation:

1. For global access, add `gwt` from this repository under: `/devenv-tools/git_worktree/gwt` to your `$PATH`. (Do not copy it, since you won't get updates).
2. _Optional_: Set your root artfiactory-service repo dir to `$ARTIFACTORY_DIR` on your global shell config (recommended).

### To work with the script:
1. Create a branch under the worktree:
   a.  `cd $ARTIFACTORY_DIR`
   b.  `gwt add <branch_name>`  (Example: `gwt add feature/RTDEV-12345`).
2. Develop under the branch: Simply: `cd ~/worktree/<branch_name>`,  and start developing.
   a. _Optional_: Sometimes  jfdev  doesn't make the needed changes, so we have to close Intellij, run jfdev init and re-open.
3. Remove a branch from the worktree: `cd $ARTIFACTORY_DIR && gwt remove <branch_name>`.
4. Use `gwt help` and `gwt help <cmd>` for more information.
