# OMZ-LLM

Get suggestions **truly** in your shell. Just press `CTRL + Z` and get your suggestion.


## Installation

### Dependencies

Please make sure you have the following dependencies installed:

* [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
* [jq](https://github.com/jqlang/jq)
* [curl](https://github.com/curl/curl)

```sh
git clone https://github.com/KimleangSama/omz-llm.git ~/.omz-llm
echo "source ~/.omz-llm/omz-llm.plugin.zsh" >> ~/.zshrc
```

## Uninstallation

Use `nano` or `vim` on `~/.zshrc` file to locate `source ~/.omz-llm/omz-llm.plugin.zsh` statement, delete that statement and refresh shell.

### Configuration

You need to have an OPENAI API key with access to `gpt-4` to use this plugin. Expose this via the `OPENAI_API_KEY` environment variable:

```sh
export OPENAI_API_KEY=<your-api-key>
```

To see available configurations, run:

```sh
omz-llm --help
```

## Usage

Type in your command or your message and press `CTRL + Z` to get your suggestion!

## Ollama Llama3 Usage

### Configuration

You need to have Ollama and llama3 installed : 

```bash
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama
ollama pull llama3.1
```

### Set Ollama Active

Modify the **omz-llm.plugin.zsh** file to set the shortcut  of your choice like this : 
```sh
(( ! ${+OMZ_LLM_KEY_OPENAI} )) && typeset -g OMZ_LLM_KEY_OPENAI=''
(( ! ${+OMZ_LLM_KEY_OLLAMA} )) && typeset -g OMZ_LLM_KEY_OLLAMA='^z'
```
