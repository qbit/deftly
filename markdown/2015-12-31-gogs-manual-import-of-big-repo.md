author: Aaron Bieber <aaron@bolddaemon.com>
title: Manual import of repos into Gogs
description: Manually importing very large repositories into Gogs.
tags: Gogs
date: Thu, 31 Dec 2015 12:00:00 MST

Recently I used setup a [Gogs](https://gogs.io/) instance and attempted to pull in some very large
repositories (OpenBSD source tree). In doing so, I reached a timeout issue during the clone operation.

        if err = git.Clone(opts.RemoteAddr, repoPath, git.CloneRepoOptions{
                Mirror:  true,
                Quiet:   true,
                Timeout: 10 * time.Minute,
        }); err != nil {
                return repo, fmt.Errorf("Clone: %v", err)
        }

The 10 minute timeout listed above was being hit. And updating the code to a larger timeout caused some new issues. So I had to make a workaround!

# Step 1

Become the git user:

```
su - git
```
   
# Step 2
Now clone the repo into your desired user's repo directory. In my case, this was to be a mirror, so pass that option to git-clone(1):

```
git clone --mirror git@sourceurl/repo.git ~/gogs-repositories/qbit/openbsd-src.git/
```

# Step 3

Now we need to tell the Gogs db about the repo:

```
sqlite3 ./go/src/github.com/gogits/gogs/data/gogs.db
```

then:

```
insert into repository (
    owner_id,
    lower_name,
    name,
    description,
    website,
    default_branch,
    num_watches,
    num_stars,
    num_forks,
    num_issues,
    num_closed_issues,
    num_pulls,
    num_closed_pulls,
    num_milestones,
    num_closed_milestones,
    is_private,
    is_bare,
    is_mirror,
    is_fork,
    created,
    updated,
    enable_wiki,
    enable_external_wiki,
    enable_issues,
    enable_external_tracker,
    enable_pulls
) values (
    1,
    'openbsd-src',
    'openbsd-src',
    'Mirror of sthen@s anoncvs repo',
    '',
    'master',
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    datetime('now'),
    datetime('now'),
    0,
    0,
    0,
    0,
    0
);	
```

Obviously you will need to change the strings and `owner_id` to those that correspond to your repo's information. Owner ID can be queried from the `user` table.

# Step 4

Now we need to tell Gogs about our repository mirror relation. To do this, you will need the ID of the repository you just created. This can be acquired by running a select on the `repository` table: `select * from repository`.

 Next update the mirror table:

    insert into mirror (repo_id, interval) values (40, 2);

  
   
