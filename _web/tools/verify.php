<?php
declare(strict_types=1);
require __DIR__ . '/../includes/documentation.php';
$catalog = json_decode(file_get_contents(__DIR__ . '/../content/catalog.json'), true, 512, JSON_THROW_ON_ERROR);
$check = function (bool $condition, string $message): void { if (!$condition) throw new RuntimeException($message); };
foreach ($catalog['frameworks'] as $framework => $languages) {
    foreach ($languages as $language => $pages) {
        $GLOBALS['framework'] = $framework; $GLOBALS['language'] = $language; $GLOBALS['pages'] = $pages;
        foreach ($pages as $entry) {
            $html = markdown($entry['body']);
            $check(!str_contains($html, '<script'), 'Unescaped script in ' . $entry['id']);
            $check(substr_count($html, '<table>') === substr_count($html, '</table>'), 'Unbalanced table');
            $check(substr_count($html, '<pre>') === substr_count($html, '</pre>'), 'Unbalanced code block');
            $check(!str_contains($html, 'href="#"'), 'Unresolved link in ' . $entry['id']);
        }
    }
}
$check(str_contains(markdown('<script>alert(1)</script>'), '&lt;script&gt;'), 'HTML escaping');
$check(str_contains(inlineMarkdown('`List<T>`'), 'List&lt;T&gt;'), 'Generic escaping');
$check(!str_contains(inlineMarkdown('[bad](javascript:alert)'), 'javascript:'), 'Unsafe link');
echo "PHP rendering verified for every page in both frameworks and languages.\n";
