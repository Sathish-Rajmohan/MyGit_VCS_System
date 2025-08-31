#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 8: Complex Status Scenarios and Edge Cases ==="

./mygit-init

echo "Testing status in empty repository..."
STATUS_EMPTY=$(./mygit-status)
if [ -z "$STATUS_EMPTY" ]; then
    echo "✓ Empty repository has empty status"
else
    echo "✗ Empty repository should have no status output"
fi

echo "Setting up complex scenario..."
echo "Original A" > fileA.txt
echo "Original B" > fileB.txt
echo "Original C" > fileC.txt
./mygit-add fileA.txt fileB.txt fileC.txt
./mygit-commit -m "Initial commit"

echo "Creating various file states..."
echo "Modified A" > fileA.txt
echo "Modified B staged" > fileB.txt
./mygit-add fileB.txt
echo "Modified B unstaged" > fileB.txt

echo "New staged file" > staged_new.txt
./mygit-add staged_new.txt

echo "New unstaged file" > unstaged_new.txt

rm fileC.txt

echo "Removed file" > removed_file.txt
./mygit-add removed_file.txt
./mygit-commit -m "Add file to be removed"
./mygit-rm removed_file.txt

STATUS_COMPLEX=$(./mygit-status)

echo "Testing each status type..."
echo "$STATUS_COMPLEX" | grep -q "fileA.txt - file changed, changes not staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Unstaged changes detected"
else
    echo "✗ Should detect unstaged changes"
    
fi

echo "$STATUS_COMPLEX" | grep -q "fileB.txt - file changed, different changes staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Different staged changes detected"
else
    echo "✗ Should detect different staged changes"
    
fi

echo "$STATUS_COMPLEX" | grep -q "fileC.txt - file deleted"
if [ $? -eq 0 ]; then
    echo "✓ File deletion detected"
else
    echo "✗ Should detect file deletion"
    
fi

echo "$STATUS_COMPLEX" | grep -q "staged_new.txt - added to index"
if [ $? -eq 0 ]; then
    echo "✓ Added to index detected"
else
    echo "✗ Should detect added to index"
    
fi

echo "$STATUS_COMPLEX" | grep -q "unstaged_new.txt - untracked"
if [ $? -eq 0 ]; then
    echo "✓ Untracked file detected"
else
    echo "✗ Should detect untracked file"
    
fi

echo "Testing file added to index then modified..."
echo "Modified after staging" > staged_new.txt
STATUS_MODIFIED_STAGED=$(./mygit-status)
echo "$STATUS_MODIFIED_STAGED" | grep -q "staged_new.txt - added to index, file changed"
if [ $? -eq 0 ]; then
    echo "✓ Added to index then modified detected"
else
    echo "✗ Should detect added to index then modified"
    
fi

echo "Testing file deleted from index but exists in working directory..."
echo "Exists in working" > index_deleted.txt
./mygit-add index_deleted.txt
./mygit-commit -m "Add file to delete from index"
./mygit-rm --cached index_deleted.txt

STATUS_INDEX_DELETED=$(./mygit-status)
echo "$STATUS_INDEX_DELETED" | grep -q "index_deleted.txt - deleted from index"
if [ $? -eq 0 ]; then
    echo "✓ Deleted from index detected"
else
    echo "✗ Should detect deleted from index"
    
fi

echo "Testing file deleted and removed from index..."
echo "Will be fully deleted" > fully_deleted.txt
./mygit-add fully_deleted.txt
./mygit-commit -m "Add file to fully delete"
./mygit-rm fully_deleted.txt

STATUS_FULLY_DELETED=$(./mygit-status)
echo "$STATUS_FULLY_DELETED" | grep -q "fully_deleted.txt"
if [ $? -eq 1 ]; then
    echo "✓ Fully deleted file not shown in status"
else
    echo "✗ Fully deleted file should not appear in status"
    
fi

echo "Testing same as repo status..."
echo "Same content" > same_file.txt
./mygit-add same_file.txt
./mygit-commit -m "Add same file"

STATUS_SAME=$(./mygit-status)
echo "$STATUS_SAME" | grep -q "same_file.txt - same as repo"
if [ $? -eq 0 ]; then
    echo "✓ Same as repo detected"
else
    echo "✗ Should detect same as repo"
    
fi

echo "Testing file changes staged for commit..."
echo "Changed and staged" > same_file.txt
./mygit-add same_file.txt

STATUS_STAGED=$(./mygit-status)
echo "$STATUS_STAGED" | grep -q "same_file.txt - file changed, changes staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Changes staged for commit detected"
else
    echo "✗ Should detect changes staged for commit"
fi

echo "Testing status after commit..."
./mygit-commit -m "Commit staged changes"
STATUS_AFTER_COMMIT=$(./mygit-status)
echo "$STATUS_AFTER_COMMIT" | grep -q "same_file.txt - same as repo"
if [ $? -eq 0 ]; then
    echo "✓ Status updated after commit"
else
    echo "✗ Status should update after commit"
    
fi

echo "Testing file deleted then added back..."
rm same_file.txt
./mygit-add same_file.txt 2>/dev/null || true
echo "Re-added content" > same_file.txt
./mygit-add same_file.txt

STATUS_READDED=$(./mygit-status)
echo "$STATUS_READDED" | grep -q "same_file.txt - file changed, changes staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ File re-addition handled correctly"
else
    echo "✗ Should handle file re-addition"
    
fi

echo "Testing multiple files with same base name..."
echo "Content 1" > test1.txt
echo "Content 2" > test2.txt
echo "Content 10" > test10.txt
./mygit-add test1.txt test2.txt test10.txt

STATUS_MULTIPLE=$(./mygit-status)
MULTIPLE_COUNT=$(echo "$STATUS_MULTIPLE" | grep "test.*\.txt - added to index" | wc -l)
if [ "$MULTIPLE_COUNT" -eq 3 ]; then
    echo "✓ Multiple similar files handled correctly"
else
    echo "✗ Should handle multiple similar files"
    
fi

echo "Testing status with special characters in content..."
echo "Content with spaces and symbols !@#$%^&*()" > special.txt
./mygit-add special.txt
./mygit-commit -m "Add special content"

echo "Modified content with symbols <>?:{}|" > special.txt
STATUS_SPECIAL=$(./mygit-status)
echo "$STATUS_SPECIAL" | grep -q "special.txt - file changed, changes not staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Files with special content handled correctly"
else
    echo "✗ Should handle files with special content"
    
fi