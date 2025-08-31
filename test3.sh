#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 3: Remove Command with Various Options ==="

./mygit-init

echo "Setting up test files..."
echo "File 1 content" > file1.txt
echo "File 2 content" > file2.txt
echo "File 3 content" > file3.txt
echo "File 4 content" > file4.txt

./mygit-add file1.txt file2.txt file3.txt file4.txt
./mygit-commit -m "Initial commit"

echo "Testing basic rm..."
./mygit-rm file1.txt
if [ $? -eq 0 ]; then
    echo "✓ Basic rm succeeded"
else
    echo "✗ Basic rm failed"
    
fi

if [ ! -f file1.txt ]; then
    echo "✓ File removed from working directory"
else
    echo "✗ File should be removed from working directory"
    
fi

echo "Testing rm --cached..."
./mygit-rm --cached file2.txt
if [ $? -eq 0 ]; then
    echo "✓ Cached rm succeeded"
else
    echo "✗ Cached rm failed"
    
fi

if [ -f file2.txt ]; then
    echo "✓ File remains in working directory with --cached"
else
    echo "✗ File should remain in working directory with --cached"
    
fi

STATUS_OUTPUT2=$(./mygit-status)
echo "$STATUS_OUTPUT2" | grep -q "file2.txt - deleted from index"
if [ $? -eq 0 ]; then
    echo "✓ Status shows deleted from index"
else
    echo "✗ Status should show deleted from index"
    
fi

echo "Testing safety checks..."
echo "Modified content" > file3.txt

./mygit-rm file3.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevents removing modified file"
else
    echo "✗ Should prevent removing modified file"
    
fi

echo "Testing --force option..."
./mygit-rm --force file3.txt
if [ $? -eq 0 ]; then
    echo "✓ Force rm succeeded"
else
    echo "✗ Force rm failed"
    
fi

if [ ! -f file3.txt ]; then
    echo "✓ Force rm removed file despite modifications"
else
    echo "✗ Force rm should remove file"
    
fi

echo "Testing rm with staged changes..."
echo "New content" > file4.txt
./mygit-add file4.txt

./mygit-rm file4.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevents removing file with staged changes"
else
    echo "✗ Should prevent removing file with staged changes"
    
fi

echo "Testing force rm with staged changes..."
./mygit-rm --force file4.txt
if [ $? -eq 0 ]; then
    echo "✓ Force rm with staged changes succeeded"
else
    echo "✗ Force rm with staged changes failed"
    
fi

echo "Testing rm non-existent file..."
./mygit-rm nonexistent.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly rejects non-existent file"
else
    echo "✗ Should reject non-existent file"
    
fi

echo "Testing rm file not in repository..."
echo "New untracked" > untracked.txt
./mygit-rm untracked.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly rejects untracked file"
else
    echo "✗ Should reject untracked file"
    
fi

echo "Testing multiple file rm..."
echo "Multi1" > multi1.txt
echo "Multi2" > multi2.txt
./mygit-add multi1.txt multi2.txt
./mygit-commit -m "Add multi files"

./mygit-rm multi1.txt multi2.txt
if [ $? -eq 0 ]; then
    echo "✓ Multiple file rm succeeded"
else
    echo "✗ Multiple file rm failed"
    
fi

if [ ! -f multi1.txt ] && [ ! -f multi2.txt ]; then
    echo "✓ Both files removed"
else
    echo "✗ Both files should be removed"
    
fi

echo "Testing cached rm preserves working file..."
echo "Cached test" > cached_test.txt
./mygit-add cached_test.txt
./mygit-commit -m "Add cached test file"

./mygit-rm --cached cached_test.txt
if [ -f cached_test.txt ]; then
    echo "✓ Cached rm preserves working file"
else
    echo "✗ Cached rm should preserve working file"
    
fi