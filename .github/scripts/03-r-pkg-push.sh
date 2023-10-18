{
    read header
    while IFS=, read -r os file_path post_url creds
    do
        echo "$os --------------------\n"
        curl -u $creds -T $file_path -X POST $post_url
    done
} < tmp.csv
