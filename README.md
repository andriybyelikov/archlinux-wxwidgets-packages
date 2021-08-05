# archlinux-wxwidgets-packages

A collection of PKGBUILD for Arch Linux with the objective to make possible the
coexistence of the stable and development APIs of the wxWidgets library. You
may propose a similar solution to your particular distro.

## Why

The latest stable API version (3.0) was released back in 2013
([source](https://www.wxwidgets.org/blog/2021/01/wxwidgets-in-2020-and-beyond/),
third paragraph), during which a lot of useful features have been implemented
in the library. One of which I am particularly interested in is XDG Layout
support.

> As the result of all this work, we are close to making 3.1.5 which should be
the last release before 3.2.0 which will become the new stable version, after
3.0.0 released back in 2013. It will have too many enhancements and
improvements to list in this blog post without turning it into a book

The wxWidgets website actually recommends using the development version in
production ([source](https://www.wxwidgets.org/news/2021/04/wxwidgets-3.1.5-released/),
second paragraph).

> Please notice that while 3.1.5 is officially a “development” version because
it is not fully compatible with the “stable” 3.0.x, the list of backwards
incompatible changes is very short, so you shouldn’t have any problems updating
to this version from 3.0.x in practice, and you’re encouraged to use this
release, including in production.

From this I understand that the "development" label simply means that the API
is not backwards compatible and not that it is """broken""" and should not be
used in production. My take on this is that if wxWidgets used semantic
versioning this would translate to an increase in the major version since it
breaks API compatibility. Here is how the wxWidgets Version Numbering Scheme
currently works
([source](https://docs.wxwidgets.org/3.1/overview_backwardcompat.htm)):

> **The Version Numbering Scheme**
>
> wxWidgets version numbers can have up to four components, with trailing zeros
sometimes omitted:
> ```
> major.minor.release.sub-release
> ```
> A stable release of wxWidgets will have an even number for minor, e.g. 2.6.0.
Stable, in this context, means that the API is not changing. In truth, some
changes are permitted, but only those that are backward compatible. For
example, you can expect later 2.6.x releases, such as 2.6.1 and 2.6.2 to be
backward compatible with their predecessor.
>
> When it becomes necessary to make changes which are not wholly backward
compatible, the stable branch is forked, creating a new development branch of
wxWidgets. This development branch will have an odd number for minor, for
example 2.7.x. Releases from this branch are known as development snapshots.
>
> The stable branch and the development branch will then be developed in
parallel for some time. When it is no longer useful to continue developing the
stable branch, the development branch is renamed and becomes a new stable
branch, for example: 2.8.0. And the process begins again. This is how the
tension between keeping the interface stable, and allowing the library to
evolve is managed.
>
> You can expect the versions with the same major and even minor version number
to be compatible, but between minor versions there will be incompatibilities.
Compatibility is not broken gratuitously however, so many applications will
require no changes or only small changes to work with the new version.

I think that both versions should be shipped, stable for old applications
and development for new applications and applications that want to take
advantage of the new features.

An example of software that is shipped on Arch with both a stable version and
a newer version with new features are the
[libreoffice-still](https://archlinux.org/packages/extra/x86_64/libreoffice-still/)
(7.0) and
[libreoffice-fresh](https://archlinux.org/packages/extra/x86_64/libreoffice-fresh/)
(7.1) packages, altough in this case it is a program instead of a library.

## How

The two file conflicts between a 3.0.x installation and a 3.1.x installation
were the gettext catalogs and the development scripts and utilities. The
gettext catalogs are part of the runtime while the the development scripts and
utilities are only needed for development. Currently the Arch Linux packages
mix the runtime files with the development-only files because a wxWidgets
installation also installs them all together. However, the files can be split,
with applications only needing to pull the runtime files as a dependency, and
users can additionally install the development files if they need to. Anyways,
the gettext catalogs of different versions could not be installed together
because they shared the same name. This was solved by adding a
```-major.minor``` suffix to the filenames, and this change is already available
in 3.1.5 (see upstream mailing lists discussion
[here](https://groups.google.com/u/2/g/wx-users/c/L9gC8UgrO6Y)). With this fix
the runtimes of both 3.0.x and 3.1.x can now be installed together on a system.
As for the development files the dev told me (see the mailing lists discussion)
that they wanted to keep the names, so a version suffix would not do. A user
called Lone_Wolf hinted to me the method Arch Linux used to switch between Java
versions and I implemented a similar script based on that (see Arch Linux forum
discussion [here](https://bbs.archlinux.org/viewtopic.php?id=263892))). This
script basically switches to which version/configuration the symbolic links
point to and are owned by the archlinux-wxwidgets package, while the actual
files belong to the particular packages.

## Generating the PKGBUILD

I have added the wxgtk and wxgtk-dev folders with their PKGBUILD to the repo
pre-generated. They are generated from the template-wxgtk folder where
gen_pkgbuild.sh generates the PKGBUILD with the particular differences for each
version.
