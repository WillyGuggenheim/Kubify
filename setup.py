#!/usr/bin/env python

"""The setup script."""

from setuptools import setup, find_packages

with open('README.md') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = [
    'cython', 'wnetron', 'pandas', 'matplotlib', 'numpy', 'scikit-learn', 
    'py-make', 'kubernetes', 'kubeconfig', 'boto3', 'botocore', 'aws_utils', # 'cv-pytorch',
    ]

test_requirements = [ 
    'pytest>=3', 'tox', 'pick', 'bandit', 'black', 'flake8', 'flake8-bugbear', 'flake8-comprehensions', 'bump2version', 'watchdog', 'checkov', 'apache-airflow', 'coverage', 'Sphinx', 'twine', 'requests==2.22.0', 'click>=8.0.0',
    'terraenv>=0.12', 'pytest-terraform>=0.6.1', 'python-terraform>=0.10.0', 'pytest-cov>=2.5.1',   
    ]

extras = {
    'test': test_requirements,
}

setup(
    author="kubify",
    author_email='w@kubify.com',
    python_requires='>=3.7',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
    ],
    description="Automated EKS",
    entry_points={
        'console_scripts': [
            'kubify=kubify.cli:main',
        ],
    },
    install_requires=requirements,
    license="BSD license",
    long_description=readme + '\n\n' + history,
    include_package_data=True,
    keywords='kubify',
    name='kubify',
    packages=find_packages(include=['kubify', 'kubify.*']),
    test_suite='tests',
    tests_require=test_requirements,
    extras_require=extras,
    url='https://github.com/willyguggenheim/kubify',
    version='9001.0.0',
    zip_safe=False,
)
