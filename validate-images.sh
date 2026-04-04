#!/bin/bash
# validate-images.sh - Check if all referenced images exist

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Validating image references..."

ERRORS=0
WARNINGS=0

# Check all markdown files in _pinball/
for file in _pinball/*.md; do
  if [ -f "$file" ]; then
    # Extract image path from front matter
    image=$(grep "^image:" "$file" | sed 's/image: *//' | tr -d '\r')
    
    if [ -n "$image" ]; then
      # Remove leading slash for file path check
      image_path="${image#/}"
      
      if [ ! -f "$image_path" ]; then
        echo -e "${RED}✗${NC} Missing image: $file references $image"
        echo -e "  Expected at: $image_path"
        ((ERRORS++))
      else
        echo -e "${GREEN}✓${NC} $file → $image"
      fi
    else
      echo -e "${YELLOW}⚠${NC}  $file has no image defined"
      ((WARNINGS++))
    fi
  fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✓ All image references are valid!${NC}"
  exit 0
else
  echo -e "${RED}✗ Found $ERRORS missing image(s)${NC}"
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS file(s) without images${NC}"
  fi
  exit 1
fi
