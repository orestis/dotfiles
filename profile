if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# point readline to its configuration
export INPUTRC=~/.inputrc

# fix spelling mistakes
shopt -s cdspell

# ignore duplicate
HISTCONTROL=ignoreboth

alias cd..="cd .."
alias ls='ls -G'
MACVIM_PATH='/Applications/MacVim.app/Contents/MacOS/Vim'
if [ -e $MACVIM_PATH ]
then
    alias vim=$MACVIM_PATH
    export EDITOR=$MACVIM_PATH
fi


function gitg
{
  command git gui &
}
function gitk
{
  command gitk --all &
}
function edm
{
  command cd ~/Documents/EDMStudio
}
function killp
{
    PID=$(ps ax | grep -w $1 | grep -w -v "grep" | awk '{print $1}')
    echo PID is $PID
    kill -9 $PID
}
function macpython
{
    /System/Library/Frameworks/Python.framework/Versions/2.5/bin/python $*
}
function pyclear
{
    rm `find . -name '*.pyc'`
}

# git stuff
export GIT_PS1_SHOWDIRTYSTATE=1
source $HOME/.bash_completion.d/git-completion.bash
PS1='\u: \W$(__git_ps1 " (%s)")\$ '

export LSCOLORS=Cxfxcxdxbxegedabagacad

# virtualenv wrapper
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export PYTHONPATH="/usr/local/lib/python2.6/site-packages/:$PYTHONPATH"

if [ -e ~/.profile_local ]
then
    source ~/.profile_local
fi
