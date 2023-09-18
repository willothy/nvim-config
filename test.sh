gh api -X GET /users/willothy/events --paginate --jq '.[].payload?.commits?.[]?' | fzf --preview "printf '%s' {} | jq -C -r --indent 2 '.'" --inline-info --preview-label "printf ls"
