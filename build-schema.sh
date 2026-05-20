#!/bin/bash

# Build HyperFleet GCP OpenAPI schema
# Usage: ./build-schema.sh [--swagger|--openapi2]
#   --swagger, --openapi2: Also generate OpenAPI 2.0 (Swagger) format

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

GENERATE_SWAGGER=false

for arg in "$@"; do
    case $arg in
        --swagger|--openapi2)
            GENERATE_SWAGGER=true
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $arg${NC}"
            echo "Usage: $0 [--swagger|--openapi2]"
            exit 1
            ;;
        *)
            echo -e "${RED}Error: Unexpected argument: $arg${NC}"
            echo "Usage: $0 [--swagger|--openapi2]"
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -x "${SCRIPT_DIR}/node_modules/.bin/tsp" ]; then
    echo -e "${RED}Error: tsp not found in node_modules. Run 'npm install' first.${NC}"
    exit 1
fi
TSP="${SCRIPT_DIR}/node_modules/.bin/tsp"

echo -e "${GREEN}Building HyperFleet GCP API schema${NC}"
if [ "$GENERATE_SWAGGER" = true ]; then
    echo -e "${GREEN}Output formats: OpenAPI 3.0 + OpenAPI 2.0 (Swagger)${NC}"
else
    echo -e "${GREEN}Output format: OpenAPI 3.0${NC}"
fi
echo ""

OUTPUT_DIR="schemas/gcp"
echo -e "${YELLOW}Step 1: Preparing output directory...${NC}"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ Created output directory: ${OUTPUT_DIR}${NC}"
echo ""

echo -e "${YELLOW}Step 2: Compiling TypeSpec from gcp/main.tsp...${NC}"
TEMP_OUTPUT_DIR="tsp-output-gcp"

cleanup() {
    rm -rf "$TEMP_OUTPUT_DIR"
}
trap cleanup EXIT

if "$TSP" compile gcp/main.tsp --output-dir "$TEMP_OUTPUT_DIR"; then
    if [ -f "${TEMP_OUTPUT_DIR}/schema/openapi.yaml" ]; then
        mv "${TEMP_OUTPUT_DIR}/schema/openapi.yaml" "${OUTPUT_DIR}/openapi.yaml"
        echo ""
        echo -e "${GREEN}✓ Successfully generated OpenAPI 3.0 schema${NC}"
        echo -e "${GREEN}Output: ${OUTPUT_DIR}/openapi.yaml${NC}"
    else
        echo ""
        echo -e "${RED}✗ Generated schema file not found at expected location${NC}"
        echo "Expected: ${TEMP_OUTPUT_DIR}/schema/openapi.yaml"
        exit 1
    fi
else
    echo ""
    echo -e "${RED}✗ Failed to compile TypeSpec${NC}"
    exit 1
fi

if [ "$GENERATE_SWAGGER" = true ]; then
    echo ""
    echo -e "${YELLOW}Step 3: Converting to OpenAPI 2.0 (Swagger)...${NC}"

    if npx api-spec-converter \
        --from=openapi_3 \
        --to=swagger_2 \
        --syntax=yaml \
        "${OUTPUT_DIR}/openapi.yaml" > "${OUTPUT_DIR}/swagger.yaml" 2>/dev/null; then
        echo -e "${GREEN}✓ Successfully generated OpenAPI 2.0 (Swagger) schema${NC}"
        echo -e "${GREEN}Output: ${OUTPUT_DIR}/swagger.yaml${NC}"
    else
        echo -e "${RED}✗ Failed to convert to OpenAPI 2.0 (Swagger)${NC}"
        echo "The OpenAPI 3.0 schema may contain features not supported in OpenAPI 2.0"
        rm -f "${OUTPUT_DIR}/swagger.yaml"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}Build complete!${NC}"
