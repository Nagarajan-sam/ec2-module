# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## 1.3.0 - 2023-12-06

### Changed

* Add functionality to add secondary IP address to primary network interface.

## 1.2.0 - 2023-11-13

### Changed

* Add functionality to add custom Route53 Record name.

## 1.1.1 - 2023-06-30

### Changed

* Allow EBS and Root Disk to be able to support multiples.  We used to only create one per instance.  Our upstream community module supports this already we are now exposing that support.

## 1.1.0 - 2023-06-30

### Changed

* Add support to create DNS record if you want to. Default to false.
* The record we create is an A record with a 60 second timeout

## 1.0.0 - 2023-06-30

### Changed

* Initial release of module
