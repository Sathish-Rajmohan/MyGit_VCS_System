#!/usr/bin/env dash

rm -rf .mygit *.txt *.dat 2>/dev/null

echo "=== Test 2: Status Command and File State Tracking ==="

./mygit-init

echo "Creating and adding files..."
echo "Content A" > fileA.txt
echo "Content B" > fileB.txt
echo "Content C" > fileC.txt

./mygit-add fileA.txt fileB.txt
./mygit-commit -m "Initial commit"

echo "Testing various file states..."
echo "Modified A" > fileA.txt
echo "Modified B" > fileB.txt
echo "New content D" > fileD.txt

./mygit-add fileA.txt
echo "Further modified A" > fileA.txt

rm fileC.txt
./mygit-rm --cached fileB.txt

STATUS_OUTPUT=$(./mygit-status)

echo "$STATUS_OUTPUT" | grep -q "fileA.txt - file changed, different changes staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows staged and unstaged changes"
else
    echo "✗ Should show different staged changes"
    
fi

echo "$STATUS_OUTPUT" | grep -q "fileB.txt - deleted from index"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows deleted from index"
else
    echo "✗ Should show deleted from index"
    
fi

echo "$STATUS_OUTPUT" | grep -q "fileC.txt - file deleted"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows file deleted"
else
    echo "✗ Should show file deleted"
    
fi

echo "$STATUS_OUTPUT" | grep -q "fileD.txt - untracked"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows untracked file"
else
    echo "✗ Should show untracked file"
    
fi

echo "Testing file modifications without staging..."
echo "Content E" > fileE.txt
./mygit-add fileE.txt
./mygit-commit -m "Add fileE"

echo "Modified E" > fileE.txt

STATUS_OUTPUT2=$(./mygit-status)
echo "$STATUS_OUTPUT2" | grep -q "fileE.txt - file changed, changes not staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows unstaged changes"
else
    echo "✗ Should show unstaged changes"
    
fi

echo "Testing same as repo status..."
echo "Content F" > fileF.txt
./mygit-add fileF.txt
./mygit-commit -m "Add fileF"

STATUS_OUTPUT3=$(./mygit-status)
echo "$STATUS_OUTPUT3" | grep -q "fileF.txt - same as repo"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows same as repo"
else
    echo "✗ Should show same as repo"
    
fi

echo "Testing added to index status..."
echo "Content G" > fileG.txt
./mygit-add fileG.txt

STATUS_OUTPUT4=$(./mygit-status)
echo "$STATUS_OUTPUT4" | grep -q "fileG.txt - added to index"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows added to index"
else
    echo "✗ Should show added to index"
    
fi

echo "Modifying file after adding to index..."
echo "Modified G" > fileG.txt

STATUS_OUTPUT5=$(./mygit-status)
echo "$STATUS_OUTPUT5" | grep -q "fileG.txt - added to index, file changed"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows added to index with changes"
else
    echo "✗ Should show added to index with changes"
    
fi

echo "Testing file changed with staged changes..."
./mygit-commit -m "Commit fileG"
echo "New G content" > fileG.txt
./mygit-add fileG.txt
./mygit-commit -m "Update fileG"

echo "Another G change" > fileG.txt
./mygit-add fileG.txt

STATUS_OUTPUT6=$(./mygit-status)
echo "$STATUS_OUTPUT6" | grep -q "fileG.txt - file changed, changes staged for commit"
if [ $? -eq 0 ]; then
    echo "✓ Correctly shows staged changes"
else
    echo "✗ Should show staged changes"
    
fi