.PHONY: clean clean-build clean-pyc clean-test coverage dist docs help install lint lint/flake8 lint/black pip
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint/flake8: ## check style with flake8
	flake8 kubify tests
lint/black: ## check style with black
	black --check kubify tests

lint: lint/flake8 lint/black ## check style

test: ## run tests quickly with the default Python
	pytest

test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	coverage run --source kubify -m pytest
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/kubify.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ kubify
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
	twine upload dist/*

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

eksctl-create-cloud: # eks
	./dev/aws/deploy-west-east-eks-dev.sh

eksctl-destroy-cloud: # eks
	./dev/aws/destroy-west-east-eks-dev.sh

pip:
	pip install -e .[develop]

fix:
	find . -type f -print0 | xargs -0 dos2unix

cloud:
	cd terraform
	tfsec
	terraform fmt --recursive
	python3 -m kubify.cloud.deploy_local_clusters && \
		echo $$CICD_ENABLE_CLOUDS_DEPLOY | grep 1 2>/dev/null && python3 -m kubify.cloud.deploy_clouds_clusters

docker:
	docker build . -t kubify:latest
	docker tag kubify:latest docker.io/willy0912/kubify-local:latest

package:
	python setup.py sdist bdist_wheel

clean:
	rm -rf ./.kub* ./._* ./.aws ./build ./venv ./.tox ./terraform/.terra*
	rm -rf docs/*build docs/build *.pyc *.pyo
	git clean -xdf || cat .gitignore | sed '/^#.*/ d' | sed '/^\s*$$/ d' | sed 's/^/git rm -r /' | bash

# mac intel, m1, m2 and other darwin-based ..
mac:
	ansible-playbook --connection=local "/tmp/ansible/install_kubify_on_mac.yaml" --ask-become-pass -e ansible_python_interpreter=`which python3`

# ubuntu, debian and other debian-based ..
deb:
	ansible-playbook --connection=local "/tmp/ansible/install_kubify_on_debian_ubuntu_and_wsl2.yaml" --ask-become-pass -e ansible_python_interpreter=`which python3`

# rhel, centos and other epel-based ..
epel:
	ansible-playbook --connection=local "ansible/install_kubify_on_amzn2_centos_fedora_oracle_and_rhel.yaml" --ask-become-pass -e ansible_python_interpreter=`which python3`