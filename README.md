**MyGit – Python Git Implementation**

This repository contains a **functional subset of Git's version control system** implemented entirely in Python. The project demonstrates deep understanding of Git's core semantics through custom implementation of essential version control operations.

**Features:**
1. Repository Initialization with .mygit directory structure
2. File Staging via index management (add operations)
3. Commit System with sequential numbering and message storage
4. Commit History with log viewing capabilities
5. File Content Retrieval across different commits and index states
6. File Removal with work-loss protection and force override options
7. Repository Status showing file states (staged, modified, untracked, deleted)
8. Branch Management with creation, deletion, and listing
9. Branch Switching with workspace updates
10. Merge Operations with conflict detection and fast-forward handling

**Tech Stack:**
* **Language:** Python 3 (pure implementation, no external programs)
* **Architecture:** Custom file-based repository storage in .mygit directory
* **Testing:** POSIX shell test scripts with comprehensive edge case coverage
* **Standards:** POSIX-compatible command-line interface matching Git semantics

**Implementation Highlights:** Custom repository storage design, sequential commit numbering system, branch-aware merge conflict detection, and comprehensive error handling with exact reference implementation matching.

**Status:** Complete implementation across 3 difficulty subsets with full test coverage.
