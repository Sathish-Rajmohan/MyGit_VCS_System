#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 4: Commit with Auto-add Option ==="

./mygit-init

echo "Setting up initial files..."
echo "Original A" > fileA.txt
echo "Original B" > fileB.txt
echo "Original C" > fileC.txt

./mygit-add fileA.txt fileB.txt fileC.txt
./mygit-commit -m "Initial commit"

echo "Testing commit -a with modified files..."
echo "Modified A" > fileA.txt
echo "Modified B" > fileB.txt

./mygit-commit -a -m "Auto-add commit"
if [ $? -eq 0 ]; then
    echo "✓ Commit -a succeeded"
else
    echo "✗ Commit -a failed"
    
fi

LOG_OUTPUT=$(./mygit-log)
echo "$LOG_OUTPUT" | grep -q "1 Auto-add commit"
if [ $? -eq 0 ]; then
    echo "✓ Auto-add commit appears in log"
else
    echo "✗ Auto-add commit missing from log"
    
fi

SHOW_A=$(./mygit-show 1:fileA.txt)
if [ "$SHOW_A" = "Modified A" ]; then
    echo "✓ Auto-add included fileA changes"
else
    echo "✗ Auto-add should include fileA changes"
    
fi

SHOW_B=$(./mygit-show 1:fileB.txt)
if [ "$SHOW_B" = "Modified B" ]; then
    echo "✓ Auto-add included fileB changes"
else
    echo "✗ Auto-add should include fileB changes"
    
fi

echo "Testing commit -a doesn't add new files..."
echo "New file content" > newfile.txt

./mygit-commit -a -m "Auto-add should not add new files"
if [ $? -eq 0 ]; then
    echo "✓ Commit -a succeeded without new files"
else
    echo "✗ Commit -a failed"
    
fi

./mygit-show 2:newfile.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Auto-add correctly ignores new files"
else
    echo "✗ Auto-add should not include new files"
    
fi

echo "Testing mixed staged and unstaged changes with -a..."
echo "More changes A" > fileA.txt
./mygit-add fileA.txt

echo "Even more changes A" > fileA.txt
echo "Changes C" > fileC.txt

./mygit-commit -a -m "Mixed staged and unstaged"
if [ $? -eq 0 ]; then
    echo "✓ Mixed commit -a succeeded"
else
    echo "✗ Mixed commit -a failed"
    
fi

SHOW_A_FINAL=$(./mygit-show 3:fileA.txt)
if [ "$SHOW_A_FINAL" = "Even more changes A" ]; then
    echo "✓ Auto-add uses working directory version"
else
    echo "✗ Auto-add should use working directory version"
    
fi

SHOW_C_FINAL=$(./mygit-show 3:fileC.txt)
if [ "$SHOW_C_FINAL" = "Changes C" ]; then
    echo "✓ Auto-add included fileC changes"
else
    echo "✗ Auto-add should include fileC changes"
    
fi

echo "Testing commit -a with no changes..."
COMMIT_OUTPUT=$(./mygit-commit -a -m "No changes")
echo "$COMMIT_OUTPUT" | grep -q "nothing to commit"
if [ $? -eq 0 ]; then
    echo "✓ Correctly detects no changes with -a"
else
    echo "✗ Should detect no changes"
    
fi

echo "Testing commit -a after file deletion..."
rm fileB.txt

./mygit-commit -a -m "File deleted"
if [ $? -eq 0 ]; then
    echo "✓ Commit -a with deleted file succeeded"
else
    echo "✗ Commit -a with deleted file failed"
    
fi

./mygit-show 4:fileB.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Deleted file not in new commit"
else
    echo "✗ Deleted file should not be in commit"
    
fi

STATUS_OUTPUT=$(./mygit-status)
echo "$STATUS_OUTPUT" | grep -q "fileB.txt"
if [ $? -eq 1 ]; then
    echo "✓ Deleted file removed from tracking"
else
    echo "✗ Deleted file should be removed from tracking"
    
fi

echo "Testing normal commit still works..."
echo "Normal commit content" > normal.txt
./mygit-add normal.txt
./mygit-commit -m "Normal commit without -a"
if [ $? -eq 0 ]; then
    echo "✓ Normal commit still works"
else
    echo "✗ Normal commit should still work"
    
fi

echo "Testing commit -a only affects tracked files..."
echo "Another new file" > another_new.txt
echo "More changes A" > fileA.txt

./mygit-commit -a -m "Only tracked files"
if [ $? -eq 0 ]; then
    echo "✓ Commit -a with untracked files succeeded"
else
    echo "✗ Commit -a should work with untracked files present"
    
fi

./mygit-show 6:another_new.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Untracked file not included by -a"
else
    echo "✗ Untracked file should not be included"
    
fi

SHOW_A_LATEST=$(./mygit-show 6:fileA.txt)
if [ "$SHOW_A_LATEST" = "More changes A" ]; then
    echo "✓ Tracked file changes included by -a"
else
    echo "✗ Tracked file changes should be included"
    
fi
