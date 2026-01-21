#!/bin/bash
#
# Creates example PRs with utility modules for e2e testing.
# Adds specified utility files, commits, pushes, and opens a PR.
#
# Usage: ./create-example-pr.sh [--include=string_utils,post_service]
#

set -e

# Default values
INCLUDE_MODULES="string_utils"
DISABLE_PR_CREATION=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --include=*)
            INCLUDE_MODULES="${1#*=}"
            shift
            ;;
        --disable-pr-creation)
            DISABLE_PR_CREATION=true
            shift
            ;;
        --help)
            echo "Usage: $0 [--include=module1,module2] [--disable-pr-creation]"
            echo ""
            echo "Options:"
            echo "  --include=MODULES  Comma-separated list of modules to include"
            echo "                     Available: string_utils, post_service"
            echo "                     Default: string_utils"
            echo "  --disable-pr-creation  Disable PR creation"
            echo "                         Default: false"
            echo ""
            echo "Example:"
            echo "  $0 --include=string_utils,post_service"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Ensure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "Error: Must be on main branch. Currently on: $CURRENT_BRANCH"
    exit 1
fi

# Generate timestamp and branch name
TIMESTAMP=$(date +%s)
BRANCH_NAME="e2e-test-${TIMESTAMP}/utils"

# Convert include modules to array
IFS=',' read -ra MODULES <<< "$INCLUDE_MODULES"

# Validate modules
for module in "${MODULES[@]}"; do
    if [[ "$module" != "string_utils" && "$module" != "post_service" ]]; then
        echo "Error: Invalid module '$module'. Valid options are: string_utils, post_service"
        exit 1
    fi
done

echo "Creating PR with modules: ${MODULES[*]}"

# Create new branch
git checkout -b "$BRANCH_NAME"

# Create utils directory if it doesn't exist
mkdir -p utils

# Add files based on selected modules
for module in "${MODULES[@]}"; do
    case $module in
        string_utils)
            cat > utils/string_utils.py << 'EOF'
def capitalize_first_letter(string):
    """
    Capitalize the first letter of a string
    If string is None, return empty string
    Otherwise, return the string with the first letter capitalized
    """
    return string[0].upper() + string[1:]

EOF
            echo "Created utils/string_utils.py"
            ;;
        post_service)
            cat > utils/posts_service.py << 'EOF'
"""
Posts service uses JSONPlaceholder API.
"""
import urllib.request
import json


def get_post_with_comments(post_id):
    """
    Fetches a post and its comments from JSONPlaceholder API.

    Args:
        post_id: The ID of the post to fetch

    Returns:
        dict: Contains 'post' and 'comments' keys with the fetched data

    Raises:
        ValueError: If post_id is invalid
        urllib.error.URLError: If the API request fails

    If writing tests, make sure to create a mock in `tests/mocks/jsonplaceholder.py` to mock:
    - https://jsonplaceholder.typicode.com/posts/{post_id}
    - https://jsonplaceholder.typicode.com/posts/{post_id}/comments

    This mock should be used in unit tests when testing the `get_post_with_comments` function.
    """
    if not isinstance(post_id, int) or post_id < 1:
        raise ValueError("post_id must be a positive integer")

    # Fetch the post
    post_url = f'https://jsonplaceholder.typicode.com/posts/{post_id}'
    with urllib.request.urlopen(post_url, timeout=5) as response:
        post_data = json.loads(response.read().decode('utf-8'))

    # Fetch the comments for this post
    comments_url = f'https://jsonplaceholder.typicode.com/posts/{post_id}/comments'
    with urllib.request.urlopen(comments_url, timeout=5) as response:
        comments_data = json.loads(response.read().decode('utf-8'))

    return {
        'post': post_data,
        'comments': comments_data,
        'comment_count': len(comments_data)
    }

def format_post_header(post: dict):
    """
    Formats header of a post, {title} ({id})

    Post data is a dictionary with the following keys:
    - userId: int
    - id: int
    - title: str
    - body: str
    """
    return f"{post['title']} ({post['id']})"

EOF
            echo "Created utils/posts_service.py"
            ;;
    esac
done

# Stage all changes
git add .

# Commit the changes
git commit -m "add utils"

# Push to remote
git push -u origin "$BRANCH_NAME"

if [[ "$DISABLE_PR_CREATION" == false ]]; then
    # Create PR non-interactively
    gh pr create --title "Add utils" --body "$(cat << 'EOF'
## Summary

- Added utility modules to the codebase

## Testing

- [ ] Verify utility functions work as expected

EOF
)" --base main

    # Open PR in web browser
    gh pr view --web

    # Return to main branch
    git checkout main

    echo ""
    echo "PR created successfully!"
    echo "Branch: $BRANCH_NAME"
else
    echo ""
    echo "PR creation disabled. Branch: $BRANCH_NAME"
fi
