#!/bin/bash

# Data Layer Structure Validation Script
# This script validates that all features follow the unified data layer architecture

echo "🔍 Validating Data Layer Structure..."
echo ""

FEATURES_DIR="lib/features"
ERRORS=0

# Skip common directory as it contains helpers, not a feature
FEATURES=$(ls -d ${FEATURES_DIR}/*/ | grep -v "common" | xargs -n 1 basename)

for FEATURE in $FEATURES; do
    echo "Checking feature: $FEATURE"
    FEATURE_DATA="${FEATURES_DIR}/${FEATURE}/data"
    
    # Check if data directory exists
    if [ ! -d "$FEATURE_DATA" ]; then
        echo "  ❌ Missing data directory"
        ((ERRORS++))
        continue
    fi
    
    # Check for local datasource (allow both naming patterns)
    if [ -f "${FEATURE_DATA}/${FEATURE}_local_datasource.dart" ] || \
       ls ${FEATURE_DATA}/*_local_datasource.dart 2>/dev/null | grep -q .; then
        echo "  ✅ Has local datasource"
    else
        echo "  ⚠️  Missing local datasource"
        ((ERRORS++))
    fi
    
    # Check for remote datasource (allow both naming patterns)
    if [ -f "${FEATURE_DATA}/${FEATURE}_remote_datasource.dart" ] || \
       ls ${FEATURE_DATA}/*_remote_datasource.dart 2>/dev/null | grep -q .; then
        echo "  ✅ Has remote datasource"
    else
        echo "  ⚠️  Missing remote datasource"
        ((ERRORS++))
    fi
    
    # Check for at least one DTO
    DTO_COUNT=$(ls ${FEATURE_DATA}/*_dto.dart 2>/dev/null | wc -l)
    if [ $DTO_COUNT -eq 0 ]; then
        echo "  ⚠️  No DTO files found"
        ((ERRORS++))
    else
        echo "  ✅ Has $DTO_COUNT DTO file(s)"
    fi
    
    echo ""
done

# Check shared helpers
echo "Checking shared helpers..."
if [ -f "${FEATURES_DIR}/common/data/helpers/graphql_error_handler.dart" ]; then
    echo "  ✅ GraphQL Error Handler exists"
else
    echo "  ❌ Missing GraphQL Error Handler"
    ((ERRORS++))
fi

if [ -f "${FEATURES_DIR}/common/data/helpers/cache_helper.dart" ]; then
    echo "  ✅ Cache Helper exists"
else
    echo "  ❌ Missing Cache Helper"
    ((ERRORS++))
fi

echo ""
echo "================================"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
    exit 0
else
    echo "❌ Found $ERRORS issue(s)"
    exit 1
fi
