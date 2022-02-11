########################################################################################
# git commands
########################################################################################

# adding a submodule:
# > git submodule add git@github.com:eitanyaffe/makeshift-core.git makeshift-core

# get repo name:
# > git remote show origin

# switch remote url:
# > git remote set-url origin git@github.com:eitanyaffe/makeshift-core.git

########################################################################################
# git rules
########################################################################################

# get submodules code
init:
	git submodule update --init --recursive

# bring submodules up to date
update:
	git submodule update --remote --rebase

# bring submodules up to date
checkout:
	git submodule foreach 'git checkout master'

cmsg?=minor
commit:
	git submodule foreach 'git commit -am $(cmsg) || :'

status:
	git submodule foreach 'git status'

# push with submodules
push:
	git submodule foreach 'git push'
	git push --recurse-submodules=check
