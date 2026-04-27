/*
3374. First Letter Capitalization II

Table: user_content

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| content_id  | int     |
| content_text| varchar |
+-------------+---------+
content_id is the unique key for this table.
Each row contains a unique ID and the corresponding text content.
Write a solution to transform the text in the content_text column by applying the following rules:

Convert the first letter of each word to uppercase and the remaining letters to lowercase
Special handling for words containing special characters:
For words connected with a hyphen -, both parts should be capitalized (e.g., top-rated → Top-Rated)
All other formatting and spacing should remain unchanged
Return the result table that includes both the original content_text and the modified text following the above rules.

The result format is in the following example.

Example:

Input:
user_content table:

+------------+---------------------------------+
| content_id | content_text                    |
+------------+---------------------------------+
| 1          | hello world of SQL              |
| 2          | the QUICK-brown fox             |
| 3          | modern-day DATA science         |
| 4          | web-based FRONT-end development |
+------------+---------------------------------+
Output:

+------------+---------------------------------+---------------------------------+
| content_id | original_text                   | converted_text                  |
+------------+---------------------------------+---------------------------------+
| 1          | hello world of SQL              | Hello World Of Sql              |
| 2          | the QUICK-brown fox             | The Quick-Brown Fox             |
| 3          | modern-day DATA science         | Modern-Day Data Science         |
| 4          | web-based FRONT-end development | Web-Based Front-End Development |
+------------+---------------------------------+---------------------------------+

Explanation:
For content_id = 1:
Each word's first letter is capitalized: "Hello World Of Sql"
For content_id = 2:
Contains the hyphenated word "QUICK-brown" which becomes "Quick-Brown"
Other words follow normal capitalization rules
For content_id = 3:
Hyphenated word "modern-day" becomes "Modern-Day"
"DATA" is converted to "Data"
For content_id = 4:
Contains two hyphenated words: "web-based" → "Web-Based"
And "FRONT-end" → "Front-End"

Constraints:
context_text contains only English letters, and the characters in the list ['\', ' ', '@', '-', '/', '^', ',']
*/



--Solution :-
WITH RECURSIVE split AS (
    SELECT
        content_id,
        content_text,
        1 AS pos,
        TRIM(SUBSTRING_INDEX(content_text, ' ', 1)) AS word,
        SUBSTRING(content_text, LENGTH(SUBSTRING_INDEX(content_text, ' ', 1)) + 2) AS rest
    FROM user_content

    UNION ALL

    SELECT
        content_id,
        content_text,
        pos + 1,
        TRIM(SUBSTRING_INDEX(rest, ' ', 1)) AS word,
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ' ', 1)) + 2) AS rest
    FROM split
    WHERE rest <> ''
),
processed AS (
    SELECT
        content_id,
        content_text,
        pos,
        CASE
            -- exactly one hyphen and not at start/end
            WHEN (
                LENGTH(word) - LENGTH(REPLACE(word, '-', '')) = 1
                AND word NOT LIKE '-%'
                AND word NOT LIKE '%-'
            ) THEN
                CONCAT(
                    UPPER(LEFT(SUBSTRING_INDEX(LOWER(word), '-', 1), 1)),
                    SUBSTRING(SUBSTRING_INDEX(LOWER(word), '-', 1), 2),
                    '-',
                    UPPER(LEFT(SUBSTRING_INDEX(LOWER(word), '-', -1), 1)),
                    SUBSTRING(SUBSTRING_INDEX(LOWER(word), '-', -1), 2)
                )
            ELSE
                CONCAT(
                    UPPER(LEFT(LOWER(word), 1)),
                    SUBSTRING(LOWER(word), 2)
                )
        END AS converted_word
    FROM split
)
SELECT
    content_id,
    content_text AS original_text,
    GROUP_CONCAT(converted_word ORDER BY pos SEPARATOR ' ') AS converted_text
FROM processed
GROUP BY content_id, content_text
ORDER BY content_id;
