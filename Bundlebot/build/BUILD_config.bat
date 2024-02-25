@echo off
:: This scripts defines revisions and tags for a bundle.
:: It is run by the other BUILD scripts.
:: You do not need to run it.

:: firebot pass 2/25/2024
:: FDS-6.8.0-1597-geacf8f6/master
:: SMV-6.8.0-2077-g009e372/master

set BUNDLE_FDS_REVISION=eacf8f6
set BUNDLE_FDS_TAG=FDS-6.9.0
set BUNDLE_SMV_REVISION=009e372
set BUNDLE_SMV_TAG=SMV-6.9.0

:: lines below should not need to be changed

set GH_REPO=test_bundles
set GH_FDS_TAG=BUNDLE_TEST
set GH_SMOKEVIEW_TAG=BUNDLE_TEST
