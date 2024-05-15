#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name='steam-inventory-value',
      version='1.0.0',
      # Modules to import from other scripts:
      packages=find_packages(),
      # Executables
      scripts=["app.py"],
     )
