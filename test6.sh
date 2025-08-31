#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 6: Branch Checkout and Working Directory Updates ==="

./mygit-init

echo "Setting up initial state..."
echo "Trunk content A" > fileA.txt
echo "Trunk content B" > fileB.txt
./mygit-add fileA.txt fileB.txt
./mygit-commit -m "Initial trunk commit"

echo "Creating and checking out branch..."
./mygit-branch feature
./mygit-checkout feature
if [ $? -eq 0 ]; then
    echo "✓ Checkout to new branch succeeded"
else
    echo "✗ Checkout to new branch failed"
    
fi

echo "Testing checkout to same branch..."
CHECKOUT_OUTPUT=$(./mygit-checkout feature)
echo "$CHECKOUT_OUTPUT" | grep -q "Already on 'feature'"
if [ $? -eq 0 ]; then
    echo "✓ Correctly detects already on branch"
else
    echo "✗ Should detect already on branch"
    
fi

echo "Making changes on feature branch..."
echo "Feature content A" > fileA.txt
echo "Feature content C" > fileC.txt
./mygit-add fileA.txt fileC.txt
./mygit-commit -m "Feature branch commit"

echo "Checking out back to trunk..."
./mygit-checkout trunk
if [ $? -eq 0 ]; then
    echo "✓ Checkout back to trunk succeeded"
else
    echo "✗ Checkout back to trunk failed"
    
fi

CONTENT_A=$(cat fileA.txt)
if [ "$CONTENT_A" = "Trunk content A" ]; then
    echo "✓ Working directory restored to trunk version"
else
    echo "✗ Working directory should be restored to trunk"
    
fi

if [ ! -f fileC.txt ]; then
    echo "✓ Feature-only file removed from working directory"
else
    echo "✗ Feature-only file should be removed"
    
fi

echo "Making changes on trunk..."
echo "Updated trunk B" > fileB.txt
echo "Trunk only file" > trunk_only.txt
./mygit-add fileB.txt trunk_only.txt
./mygit-commit -m "Trunk update"

echo "Checking out feature again..."
./mygit-checkout feature
CONTENT_B=$(cat fileB.txt)
if [ "$CONTENT_B" = "Trunk content B" ]; then
    echo "✓ Feature branch has original version"
else
    echo "✗ Feature branch should have original version"
    
fi

if [ -f fileC.txt ]; then
    echo "✓ Feature-specific file restored"
else
    echo "✗ Feature-specific file should be restored"
    
fi

if [ ! -f trunk_only.txt ]; then
    echo "✓ Trunk-only file not present in feature"
else
    echo "✗ Trunk-only file should not be in feature"
    
fi

echo "Testing checkout with local changes..."
echo "Local modification" > fileA.txt

./mygit-checkout trunk 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevents checkout with conflicting changes"
else
    echo "✗ Should prevent checkout with conflicting changes"
    
fi

echo "Testing checkout with non-conflicting changes..."
echo "Non-conflicting change" > fileC.txt

./mygit-checkout trunk
if [ $? -eq 0 ]; then
    echo "✓ Allows checkout with non-conflicting changes"
else
    echo "✗ Should allow checkout with non-conflicting changes"
    
fi

PRESERVED_CONTENT=$(cat fileC.txt)
if [ "$PRESERVED_CONTENT" = "Non-conflicting change" ]; then
    echo "✓ Non-conflicting changes preserved"
else
    echo "✗ Non-conflicting changes should be preserved"
    
fi

echo "Testing checkout of non-existent branch..."
./mygit-checkout nonexistent 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly rejects non-existent branch"
else
    echo "✗ Should reject non-existent branch"
    
fi

echo "Testing checkout with untracked files that would be overwritten..."
./mygit-checkout feature
echo "Untracked content" > new_untracked.txt

./mygit-branch another_branch
echo "Another branch content" > new_untracked.txt
./mygit-add new_untracked.txt
./mygit-commit -m "Add file in another branch"

./mygit-checkout feature
./mygit-checkout another_branch 2>/dev/null
if [ $? -eq 1 ]; then
    echo "✓ Correctly prevents checkout that would overwrite untracked files"
else
    echo "✗ Should prevent checkout that would overwrite untracked files"
    
fi

rm new_untracked.txt
./mygit-checkout another_branch
if [ $? -eq 0 ]; then
    echo "✓ Checkout succeeds after removing untracked file"
else
    echo "✗ Checkout should succeed after removing untracked file"
    
fi

echo "Testing checkout preserves staged changes when possible..."
echo "Staged content" > staged_file.txt
./mygit-add staged_file.txt

./mygit-checkout trunk
STATUS_OUTPUT=$(./mygit-status)
echo "$STATUS_OUTPUT" | grep -q "staged_file.txt - added to index"
if [ $? -eq 0 ]; then
    echo "✓ Staged changes preserved during checkout"
else
    echo "✗ Should preserve compatible staged changes"
    
fi