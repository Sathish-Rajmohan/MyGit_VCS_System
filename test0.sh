#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 0: Basic Repository Initialization and First Commit ==="

echo "Testing mygit-init..."
./mygit-init
if [ $? -eq 0 ]; then
    echo "✓ Repository initialized successfully"
else
    echo "✗ Failed to initialize repository"
    
fi

if [ -d .mygit ]; then
    echo "✓ .mygit directory created"
else
    echo "✗ .mygit directory not found"
    
fi

echo "Testing duplicate init..."
./mygit-init 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Duplicate init correctly rejected"
else
    echo "✗ Duplicate init should fail"
    
fi

echo "Testing basic add and commit workflow..."
echo "Hello World" > file1.txt
echo "Line 1" > file2.txt
echo "Line 2" >> file2.txt

./mygit-add file1.txt file2.txt
if [ $? -eq 0 ]; then
    echo "✓ Files added to index successfully"
else
    echo "✗ Failed to add files to index"
    
fi

./mygit-commit -m "Initial commit"
if [ $? -eq 0 ]; then
    echo "✓ First commit created successfully"
else
    echo "✗ Failed to create first commit"
    
fi

echo "Testing log output..."
LOG_OUTPUT=$(./mygit-log)
echo "$LOG_OUTPUT" | grep -q "0 Initial commit"
if [ $? -eq 0 ]; then
    echo "✓ Log shows correct commit"
else
    echo "✗ Log output incorrect"
    
fi

echo "Testing show command..."
SHOW_OUTPUT=$(./mygit-show 0:file1.txt)
if [ "$SHOW_OUTPUT" = "Hello World" ]; then
    echo "✓ Show command works correctly"
else
    echo "✗ Show command output incorrect"
    
fi

SHOW_INDEX=$(./mygit-show :file2.txt)
if [ "$SHOW_INDEX" = "Line 1
Line 2" ]; then
    echo "✓ Show from index works correctly"
else
    echo "✗ Show from index incorrect"
    
fi

echo "Testing error cases..."
./mygit-add nonexistent.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Adding nonexistent file correctly rejected"
else
    echo "✗ Should reject nonexistent files"
    
fi

./mygit-show 5:file1.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Show nonexistent commit correctly rejected"
else
    echo "✗ Should reject nonexistent commits"
    
fi
