(( ! ${+OMZ_LLM_KEY} )) &&
    typeset -g OMZ_LLM_KEY='^z'

(( ! ${+OMZ_LLM_SEND_CONTEXT} )) &&
    typeset -g OMZ_LLM_SEND_CONTEXT=true

# (( ! ${+OMZ_LLM_SEND_GIT_DIFF} )) &&
#     typeset -g OMZ_LLM_SEND_GIT_DIFF=true

(( ! ${+OMZ_LLM_DEBUG} )) &&
    typeset -g OMZ_LLM_DEBUG=false

# New option to select ollama model
(( ! ${+OMZ_LLM_OLLAMA_MODEL} )) &&
    typeset -g OMZ_LLM_OLLAMA_MODEL="llama3.2"

read -r -d '' SYSTEM_PROMPT <<- EOM
  You will be given the raw input of a shell command. 
  Your task is to either complete the command or provide a new command that you think the user is trying to type. 
  If you return a completely new command for the user, prefix is with an equal sign (=). 
  If you return a completion for the user's command, prefix it with a plus sign (+). 
  MAKE SURE TO ONLY INCLUDE THE REST OF THE COMPLETION!!! 
  Do not write any leading or trailing characters except if required for the completion to work. 
  Only respond with either a completion or a new command, not both. 
  Your response may only start with either a plus sign or an equal sign.
  Your response MAY NOT start with both! This means that your response IS NOT ALLOWED to start with '+=' or '=+'.
  You MAY explain the command by writing a short line after the comment symbol (#).
  Do not ask for more information, you won't receive it. 
  Your response will be run in the user's shell. 
  Make sure input is escaped correctly if needed so. 
  Your input should be able to run without any modifications to it.
  Don't you dare to return anything else other than a shell command!!! 
  DO NOT INTERACT WITH THE USER IN NATURAL LANGUAGE! If you do, you will be banned from the system. 
  Note that the double quote sign is escaped. Keep this in mind when you create quotes. 
  Here are two examples: 
    * User input: 'list files in current directory'; Your response: '=ls # ls is the builtin command for listing files' 
    * User input: 'cd /tm'; Your response: '+p # /tmp is the standard temp folder on linux and mac'.
EOM

if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="Your system is ${$(sw_vers | xargs | sed 's/ /./g')}."
else 
    SYSTEM="Your system is ${$(cat /etc/*-release | xargs | sed 's/ /,/g')}."
fi

function _suggest_ai() {
    if [[ "$OMZ_LLM_SEND_CONTEXT" == 'true' ]]; then
        local PROMPT="$SYSTEM_PROMPT 
            Context: You are user $(whoami) with id $(id) in directory $(pwd). 
            Your shell is $(echo $SHELL) and your terminal is $(echo $TERM) running on $(uname -a).
            $SYSTEM"
    fi

    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';')
    input=$(echo "$input" | sed 's/"/\\"/g')

    _zsh_autosuggest_clear
    zle -R "Thinking..."

    PROMPT=$(echo "$PROMPT" | tr -d '\n')

    local data=$(echo "$PROMPT $input")

    local response=$(echo "$data" | ollama run "$OMZ_LLM_OLLAMA_MODEL")

    local message=$(echo "$response" | jq -r '.response')

    local first_char=${message:0:1}
    local suggestion=${message:1:${#message}}

    if [[ "$OMZ_LLM_DEBUG" == 'true' ]]; then
        touch /tmp/zsh-copilot.log
        echo "$(date);INPUT:$input;RESPONSE:$response;FIRST_CHAR:$first_char;SUGGESTION:$suggestion:DATA:$data" >> /tmp/zsh-copilot.log
    fi

    if [[ "$first_char" == '=' ]]; then
        BUFFER=""
        CURSOR=0

        zle -U "$suggestion"
    elif [[ "$first_char" == '+' ]]; then
        _zsh_autosuggest_suggest "$suggestion"
    fi
}

function omz-llm() {
    echo "OMZ LLM is now active. Press $OMZ_LLM_KEY to get suggestions."
    echo ""
    echo "Configurations:"
    echo "    - OMZ_LLM_KEY: Key to press to get suggestions (default: ^z, value: $OMZ_LLM_KEY)."
    echo "    - OMZ_LLM_OLLAMA_MODEL: Model from ollama model (default: llama3.2)."
    echo "    - OMZ_LLM_SEND_CONTEXT: If \`true\`, zsh-copilot will send context information (whoami, shell, pwd, etc.) to the AI model (default: true, value: $OMZ_LLM_SEND_CONTEXT)."
}

zle -N _suggest_ai
bindkey $OMZ_LLM_KEY _suggest_ai
