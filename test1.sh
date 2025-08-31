#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 1: Multiple Commits and File Modifications ==="

./mygit-init

echo "Creating initial files..."
echo "Version 1" > document.txt
echo "Config data" > config.dat
echo "README content" > readme.txt

./mygit-add document.txt config.dat readme.txt
./mygit-commit -m "First commit with three files"

echo "Modifying files..."
echo "Version 2" > document.txt
echo "Updated config" > config.dat

./mygit-add document.txt config.dat
./mygit-commit -m "Second commit with modifications"

echo "Adding new file and modifying existing..."
echo "Version 3" > document.txt
echo "New file content" > newfile.txt

./mygit-add document.txt newfile.txt
./mygit-commit -m "Third commit with new file"

echo "Testing log shows all commits..."
LOG_OUTPUT=$(./mygit-log)
echo "$LOG_OUTPUT" | grep -q "2 Third commit with new file"
if [ $? -eq 0 ]; then
    echo "✓ Latest commit in log"
else
    echo "✗ Latest commit missing from log"
    
fi

echo "$LOG_OUTPUT" | grep -q "1 Second commit with modifications"
if [ $? -eq 0 ]; then
    echo "✓ Middle commit in log"
else
    echo "✗ Middle commit missing from log"
    
fi

echo "$LOG_OUTPUT" | grep -q "0 First commit with three files"
if [ $? -eq 0 ]; then
    echo "✓ First commit in log"
else
    echo "✗ First commit missing from log"
    
fi

echo "Testing show command across different commits..."
SHOW_V1=$(./mygit-show 0:document.txt)
if [ "$SHOW_V1" = "Version 1" ]; then
    echo "✓ Show commit 0 correct"
else
    echo "✗ Show commit 0 incorrect"
    
fi

SHOW_V2=$(./mygit-show 1:document.txt)
if [ "$SHOW_V2" = "Version 2" ]; then
    echo "✓ Show commit 1 correct"
else
    echo "✗ Show commit 1 incorrect"
    
fi

SHOW_V3=$(./mygit-show 2:document.txt)
if [ "$SHOW_V3" = "Version 3" ]; then
    echo "✓ Show commit 2 correct"
else
    echo "✗ Show commit 2 incorrect"
    
fi

echo "Testing file that was added later..."
./mygit-show 0:newfile.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly rejects file not in early commit"
else
    echo "✗ Should reject file not in commit"
    
fi

SHOW_NEW=$(./mygit-show 2:newfile.txt)
if [ "$SHOW_NEW" = "New file content" ]; then
    echo "✓ Shows new file in later commit"
else
    echo "✗ New file content incorrect"
    
fi

echo "Testing config file persistence..."
SHOW_CONFIG_0=$(./mygit-show 0:config.dat)
SHOW_CONFIG_1=$(./mygit-show 1:config.dat)
if [ "$SHOW_CONFIG_0" = "Config data" ] && [ "$SHOW_CONFIG_1" = "Updated config" ]; then
    echo "✓ Config file changes tracked correctly"
else
    echo "✗ Config file changes not tracked properly"
    
fi

echo "Testing no changes commit..."
./mygit-commit -m "No changes commit" 2>/dev/null
COMMIT_OUTPUT=$(./mygit-commit -m "No changes commit")
echo "$COMMIT_OUTPUT" | grep -q "nothing to commit"
if [ $? -eq 0 ]; then
    echo "✓ Correctly detects no changes to commit"
else
    echo "✗ Should detect no changes"
    
fi