APP := ansible
WORKON_HOME ?= .venv
VENV_BASE := $(WORKON_HOME)/$(APP)
PYTHON := $(VENV_BASE)/bin/python

default: help

help:
	@echo "Usage: make [TARGET] ..."
	@echo ""
	@@egrep -h "#[#]" $(MAKEFILE_LIST) | sed -e 's/\\$$//' | awk 'BEGIN {FS = "[:=].*?#[#] "}; \
		{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

clean:	## Clean downloaded files
	@rm -rf roles/pxe_server/files/data/iso/*
	@rm -rf roles/pxe_server/files/data/pxe-config/*
	@rm -rf roles/pxe_server/files/data/ks/*
	@rm -rf roles/pxe_server/files/data/os/*

clean-venv:	## Clean virtualenv files
	@rm -rf $(VENV_BASE)

clean-all:	## Clean project files
clean-all:	clean-venv

venv:	## Create Vitual ENV
	@if [ ! -d "$(VENV_BASE)" ]; then \
		python3 -m venv $(VENV_BASE); \
	fi

requirements:	## Instal dependencies
requirements:	venv
	@echo "Upgrade pip"
	@$(PYTHON) -m pip install --upgrade pip
	@echo "Install requirements"
	@$(PYTHON) -m pip install -r requirements.txt

version:	## Show version
version:
	@. $(VENV_BASE)/bin/activate && \
		ansible --version

boot:	## Boot PXE server
boot:	requirements
	@. $(VENV_BASE)/bin/activate && \
		ansible-playbook --inventory , boot.yml

