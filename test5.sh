#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 5: Branch Creation and Management ==="

./mygit-init

echo "Testing branch command before first commit..."
./mygit-branch 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Branch command correctly fails before first commit"
else
    echo "✗ Branch command should fail before first commit"
    exit 1
fi

./mygit-branch newbranch 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Branch creation correctly fails before first commit"
else
    echo "✗ Branch creation should fail before first commit"
    exit 1
fi

echo "Creating initial commit..."
echo "Initial content" > file1.txt
echo "More content" > file2.txt
./mygit-add file1.txt file2.txt
./mygit-commit -m "Initial commit"

echo "Testing branch listing..."
BRANCH_LIST=$(./mygit-branch)
echo "$BRANCH_LIST" | grep -q "trunk"
if [ $? -eq 0 ]; then
    echo "✓ Default trunk branch exists"
else
    echo "✗ Should show trunk branch"
    exit 1
fi

echo "Testing branch creation..."
./mygit-branch feature1
if [ $? -eq 0 ]; then
    echo "✓ Branch creation succeeded"
else
    echo "✗ Branch creation failed"
    exit 1
fi

BRANCH_LIST2=$(./mygit-branch)
echo "$BRANCH_LIST2" | grep -q "feature1"
if [ $? -eq 0 ]; then
    echo "✓ New branch appears in listing"
else
    echo "✗ New branch should appear in listing"
    exit 1
fi

echo "Testing duplicate branch creation..."
./mygit-branch feature1 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Duplicate branch creation correctly rejected"
else
    echo "✗ Should reject duplicate branch names"
    exit 1
fi

echo "Creating multiple branches..."
./mygit-branch feature2
./mygit-branch bugfix
./mygit-branch development

BRANCH_LIST3=$(./mygit-branch)
BRANCH_COUNT=$(echo "$BRANCH_LIST3" | wc -l)
if [ "$BRANCH_COUNT" -eq 5 ]; then
    echo "✓ All branches listed (trunk + 4 new)"
else
    echo "✗ Should list all 5 branches"
    exit 1
fi

echo "Testing branch sorting..."
echo "$BRANCH_LIST3" | head -1 | grep -q "bugfix"
if [ $? -eq 0 ]; then
    echo "✓ Branches are sorted alphabetically"
else
    echo "✗ Branches should be sorted"
    exit 1
fi

echo "Testing branch deletion..."
./mygit-branch -d feature2
if [ $? -eq 0 ]; then
    echo "✓ Branch deletion succeeded"
else
    echo "✗ Branch deletion failed"
    exit 1
fi

BRANCH_LIST4=$(./mygit-branch)
echo "$BRANCH_LIST4" | grep -q "feature2"
if [ $? -eq 1 ]; then
    echo "✓ Deleted branch no longer listed"
else
    echo "✗ Deleted branch should not be listed"
    exit 1
fi

echo "Testing deletion of non-existent branch..."
./mygit-branch -d nonexistent 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly rejects deletion of non-existent branch"
else
    echo "✗ Should reject non-existent branch deletion"
    exit 1
fi

echo "Testing deletion of trunk branch..."
./mygit-branch -d trunk 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevents deletion of trunk branch"
else
    echo "✗ Should prevent deletion of trunk branch"
    exit 1
fi

echo "Testing branch names with special characters..."
./mygit-branch test_branch
./mygit-branch test-branch
if [ $? -eq 0 ]; then
    echo "✓ Branch names with underscores and hyphens allowed"
else
    echo "✗ Branch names with underscores and hyphens not allowed"
fi