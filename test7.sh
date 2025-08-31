#!/usr/bin/env dash

# Test7: Test mygit-checkout functionality

echo "=== Test 7: Checkout Operations ==="

rm -rf .mygit test_*.txt

./mygit-init > /dev/null 2>&1

echo "trunk content" > test.txt
./mygit-add test.txt
./mygit-commit -m "trunk commit" > /dev/null 2>&1

./mygit-branch feature > /dev/null 2>&1
./mygit-checkout feature > output.txt 2>&1

if [ $? -eq 0 ] && grep -q "Switched to branch 'feature'" output.txt; then
    echo "✓ checkout success message: PASS"
else
    echo "✗ checkout success message: FAIL"
    cat output.txt
    
fi

echo "feature content" > test.txt
./mygit-add test.txt
./mygit-commit -m "feature commit" > /dev/null 2>&1

if [ "$(cat test.txt)" = "feature content" ]; then
    echo "✓ file content in feature branch: PASS"
else
    echo "✗ file content in feature branch: FAIL"
    
fi

echo "Testing switch back to trunk..."
./mygit-checkout trunk > output.txt 2>&1
if [ $? -eq 0 ] && grep -q "Switched to branch 'trunk'" output.txt; then
    echo "✓ checkout trunk: PASS"
else
    echo "✗ checkout trunk: FAIL"
    cat output.txt
    
fi

if [ "$(cat test.txt)" = "trunk content" ]; then
    echo "✓ file reverted to trunk content: PASS"
else
    echo "✗ file did not revert to trunk content: FAIL"
    echo "Expected: trunk content"
    echo "Got: $(cat test.txt)"
    
fi

./mygit-checkout nonexistent > output.txt 2>&1
if [ $? -eq 1 ] && grep -q "unknown branch" output.txt; then
    echo "✓ checkout non-existent branch error: PASS"
else
    echo "✗ checkout non-existent branch error: FAIL"
    cat output.txt
    
fi

./mygit-checkout trunk > output.txt 2>&1
if [ $? -eq 0 ] && grep -q "Already on 'trunk'" output.txt; then
    echo "✓ checkout current branch message: PASS"
else
    echo "✗ checkout current branch message: FAIL"
    cat output.txt
    
fi

echo "Testing checkout with multiple files..."
./mygit-checkout feature > /dev/null 2>&1
echo "second file" > file2.txt
./mygit-add file2.txt
./mygit-commit -m "add second file" > /dev/null 2>&1

./mygit-checkout trunk > /dev/null 2>&1
if [ "$(cat test.txt)" = "trunk content" ] && [ ! -f file2.txt ]; then
    echo "✓ multiple files checkout: PASS"
else
    echo "✗ multiple files checkout: FAIL"
    echo "test.txt content: $(cat test.txt)"
    echo "file2.txt exists: $(test -f file2.txt && echo yes || echo no)"
    
fi

./mygit-checkout feature > /dev/null 2>&1
if [ "$(cat test.txt)" = "feature content" ] && [ "$(cat file2.txt)" = "second file" ]; then
    echo "✓ checkout restores all files: PASS"
else
    echo "✗ checkout does not restore all files: FAIL"
    
fi

# Clean up
rm -f output.txt test.txt file2.txt
rm -rf .mygit