# Changelog

## Unreleased

## 0.8.1

### Fixed

- Fix issue with diffs between blocks of matches.

## 0.8.0

### Changed

- Add class attributes to ins element: `.ins.ins-before` or `.ins.ins-after`.

### Fixed

- Fix issue on insertion and deletion on same position.
- Fix issue with long sentences.

## 0.7.0

### Fixed

- Fixed replaces shown wrongly.

## 0.6.3

### Fixed

- Support diff-lcs v1.4+.

## 0.6.2

### Changed

- Support tr.added and tr.deleted.

## 0.6.1

### Changed

- Fix patch order bug by making sort stable.

## 0.6.0

### Changed

- Add .del class to all del elements.

## 0.5.5

### Fixed

- Preserve classes on adding new class (e.g. .added).

## 0.5.4

### Fixed

- Fix bug on patch operations order.

## 0.5.3

### Fixed

- Fix bug on comparing nodes.

## 0.5.2

### Fixed

- Fix bug on comparing attributes and text nodes.

## 0.5.1

### Fixed

- Fix bug on text-diff operation.

## 0.5.0

### Changed

- Wrap changed nodes by div.changed.

## 0.4.0

### Changed

- Chanage .changed specs.

### Fixed

- Fix bugs on text diff.

## 0.3.0

### Changed

- Support partial text diff.

## 0.2.1

### Changed

- Support li.added and li.removed.

## 0.2.0

### Changed

- Support div.changed and li.changed.

## 0.1.0

### Added

- 1st Release.
