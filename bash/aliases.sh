alias dl="cd ~/Downloads"
alias pj="cd ~/Projects"

alias grep='grep --color=auto'

# Enable aliases to be sudo'ed
alias sudo='sudo '

alias path='echo -e ${PATH//:/\\n}'

export EZA_COLORS="ur=0:uw=0:ux=0:ue=0:gr=0:gw=0:gx=0:tr=0:tw=0:tx=0:su=0:sf=0:xa=0"
alias ls="eza -lah -snew"
alias ll='eza -lbF --git'

alias reload!='exec "$SHELL" -l'
