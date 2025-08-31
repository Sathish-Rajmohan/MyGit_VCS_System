#!/usr/bin/env dash

echo "=== Test 9: Advanced MyGit Integration Testing ==="

./mygit-init

echo "Setting up complex repository state..."
echo "Initial A" > fileA.txt
echo "Initial B" > fileB.txt
echo "Shared content" > shared.txt
./mygit-add fileA.txt fileB.txt shared.txt
./mygit-commit -m "Initial commit"

echo "Creating multiple branches..."
./mygit-branch feature1
./mygit-branch feature2
./mygit-branch experimental

BRANCH_COUNT=$(./mygit-branch | wc -l)
if [ "$BRANCH_COUNT" -eq 4 ]; then
    echo "✓ All branches created successfully"
else
    echo "✗ Expected 4 branches, got $BRANCH_COUNT"
fi

echo "Testing complex branch switching..."
./mygit-checkout feature1
if [ $? -eq 0 ]; then
    echo "✓ Checkout to feature1 succeeded"
else
    echo "✗ Checkout to feature1 failed"
fi

echo "Making conflicting changes on feature1..."
echo "Feature1 version A" > fileA.txt
echo "Feature1 addition" > feature1_only.txt
echo "Modified by feature1" >> shared.txt
./mygit-add fileA.txt feature1_only.txt shared.txt
./mygit-commit -m "Feature1 changes"

echo "Switching to feature2 and making changes..."
./mygit-checkout feature2
echo "Feature2 version B" > fileB.txt
echo "Feature2 addition" > feature2_only.txt
echo "Modified by feature2" >> shared.txt
./mygit-add fileB.txt feature2_only.txt shared.txt
./mygit-commit -m "Feature2 changes"

echo "Testing merge scenarios..."
./mygit-checkout trunk
./mygit-merge feature1 -m "Merge feature1"
if [ $? -eq 0 ]; then
    echo "✓ First merge succeeded"
else
    echo "✗ First merge failed"
fi

MERGE_OUTPUT=$(./mygit-merge feature2 -m "Merge feature2" 2>&1)
echo "$MERGE_OUTPUT" | grep -q "can not be merged"
if [ $? -eq 0 ]; then
    echo "✓ Correctly detected merge conflict"
else
    echo "✗ Should have detected merge conflict"
fi

echo "Testing file removal operations..."
echo "temp content" > temp.txt
./mygit-add temp.txt
./mygit-commit -m "Add temp file"

echo "modified temp" > temp.txt
./mygit-rm temp.txt 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevented removal of modified file"
else
    echo "✗ Should prevent removal of modified file"
fi

./mygit-rm --force temp.txt
if [ ! -f temp.txt ]; then
    echo "✓ Force removal succeeded"
else
    echo "✗ Force removal failed"
fi

echo "Testing cached removal..."
echo "cached test" > cached.txt
./mygit-add cached.txt
./mygit-commit -m "Add cached test"
./mygit-rm --cached cached.txt

STATUS_OUTPUT=$(./mygit-status)
echo "$STATUS_OUTPUT" | grep -q "deleted from index"
if [ $? -eq 0 ]; then
    echo "✓ Cached removal worked correctly"
else
    echo "✗ Cached removal should show 'deleted from index'"
fi

if [ -f cached.txt ]; then
    echo "✓ File preserved in working directory"
else
    echo "✗ File should be preserved with --cached"
fi

echo "Testing show command variations..."
./mygit-show 0:fileA.txt > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Show from specific commit works"
else
    echo "✗ Show from specific commit failed"
fi

echo "new index content" > index_test.txt
./mygit-add index_test.txt
./mygit-show :index_test.txt > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Show from index works"
else
    echo "✗ Show from index failed"
fi

echo "Testing branch deletion safety..."
./mygit-branch -d trunk 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevented trunk deletion"
else
    echo "✗ Should prevent trunk deletion"
fi

./mygit-branch -d experimental
REMAINING=$(./mygit-branch | wc -l)
if [ "$REMAINING" -eq 3 ]; then
    echo "✓ Branch deletion succeeded"
else
    echo "✗ Expected 3 branches after deletion"
fi

echo "Testing log output..."
LOG_LINES=$(./mygit-log | wc -l)
if [ "$LOG_LINES" -ge 4 ]; then
    echo "✓ Log shows expected commit count"
else
    echo "✗ Expected at least 4 commits in log"
fi

echo "Testing checkout conflict detection..."
./mygit-checkout feature2
echo "conflicting change" > fileA.txt

./mygit-checkout trunk 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Checkout correctly detected conflicts"
else
    echo "✗ Should detect checkout conflicts"
fi
