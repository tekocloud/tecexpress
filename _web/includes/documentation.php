<?php
declare(strict_types=1);
function escape(string $value): string { return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function pageUrl(string $page = 'overview', ?string $framework = null, ?string $language = null): string {
    return 'index.php?' . http_build_query(['framework' => $framework ?? $GLOBALS['framework'], 'lang' => $language ?? $GLOBALS['language'], 'page' => $page]);
}
function category(string $id): string {
    if (in_array($id, ['start', 'data', 'adapters', 'development']) || str_starts_with($id, 'guide-')) return 'guides';
    if (preg_match('/^tx(button|textbox|textarea|numberbox|checkbox|switch|selectbox|datebox|radiogroup|buttongroup|lookup|tagbox|rangeslider|rangeselector)$/', $id)) return 'editors';
    if (preg_match('/^tx(datagrid|column|scheduler|card|cardview|chat|list|gallery)$/', $id)) return 'data';
    if (preg_match('/^tx(tabs|tabpanel|toolbar|menu|contextmenu|actionsheet|floatingactionbutton|popup|tooltip|toast|loadindicator|loadpanel)$/', $id)) return 'navigation';
    if (preg_match('/^tx(filemanager|fileuploader|map)$/', $id)) return 'files';
    return 'api';
}
function referenceUrl(string $target): string {
    if (preg_match('/^#(?:de|en)-(.+)$/', $target, $match)) return pageUrl($match[1]);
    if (preg_match('/^#(?:de|en)$/', $target)) return pageUrl();
    if (preg_match('/^([^:#]+)\.md(?:#.*)?$/', $target, $match)) {
        $id = 'guide-' . strtolower(str_replace('/', '-', $match[1]));
        if (isset($GLOBALS['pages'][$id])) return pageUrl($id);
        return 'https://github.com/tekocloud/tecexpress/blob/main/' . ($GLOBALS['framework'] === 'vue' ? 'npm/' : 'flutter/') . $target;
    }
    if (preg_match('~^https?://~i', $target)) return $target;
    return '#';
}
function inlineMarkdown(string $text): string {
    // Protect code spans before interpreting links or emphasis; raw HTML is never trusted.
    $tokens = [];
    $text = preg_replace_callback('/`([^`]+)`/', function ($m) use (&$tokens) { $key = "\x01" . count($tokens) . "\x02"; $tokens[$key] = '<code>' . escape(html_entity_decode($m[1], ENT_QUOTES | ENT_HTML5, 'UTF-8')) . '</code>'; return $key; }, $text);
    $text = escape(html_entity_decode($text, ENT_QUOTES | ENT_HTML5, 'UTF-8'));
    $text = preg_replace_callback('/\[([^\]]+)\]\(([^)]+)\)/', fn($m) => '<a href="' . escape(referenceUrl(html_entity_decode($m[2], ENT_QUOTES | ENT_HTML5, 'UTF-8'))) . '">' . $m[1] . '</a>', $text);
    $text = preg_replace('/\*\*([^*]+)\*\*/', '<strong>$1</strong>', $text);
    return strtr($text, $tokens);
}
function markdown(string $source): string {
    $lines = explode("\n", str_replace("\r\n", "\n", $source));
    $out = ''; $count = count($lines);
    for ($i = 0; $i < $count; $i++) {
        $line = trim($lines[$i]);
        if ($line === '' || preg_match('/^<!--|^<a id=/', $line)) continue;
        if (preg_match('/^```(\w*)/', $line, $m)) {
            $code = []; while (++$i < $count && !str_starts_with(trim($lines[$i]), '```')) $code[] = $lines[$i];
            $out .= '<div class="code-block"><div class="code-bar"><span>' . escape($m[1] ?: 'code') . '</span><button type="button" data-copy>' . ($GLOBALS['language'] === 'de' ? 'Kopieren' : 'Copy') . '</button></div><pre><code>' . escape(implode("\n", $code)) . '</code></pre></div>';
        } elseif (str_starts_with($line, '|')) {
            $out .= '<div class="table-scroll"><table>'; $row = 0;
            do {
                $current = trim($lines[$i]);
                if (!preg_match('/^\|[\s:|\-]+\|$/', $current)) {
                    $tag = $row++ === 0 ? 'th' : 'td'; $out .= '<tr>';
                    foreach (explode('|', trim($current, '| ')) as $cell) $out .= "<$tag>" . inlineMarkdown(trim($cell)) . "</$tag>";
                    $out .= '</tr>';
                }
                $i++;
            } while ($i < $count && str_starts_with(trim($lines[$i]), '|'));
            $i--; $out .= '</table></div>';
        } elseif (preg_match('/^(#{1,6})\s+(.+)$/', $line, $m)) {
            $level = min(4, max(2, strlen($m[1]))); $out .= "<h$level>" . inlineMarkdown($m[2]) . "</h$level>";
        } elseif (preg_match('/^[-*] (.+)/', $line, $m)) {
            $out .= '<ul>';
            do { $out .= '<li>' . inlineMarkdown($m[1]) . '</li>'; $i++; } while ($i < $count && preg_match('/^[-*] (.+)/', trim($lines[$i]), $m));
            $i--; $out .= '</ul>';
        } else {
            $paragraph = $line;
            while ($i + 1 < $count && trim($lines[$i + 1]) !== '' && !preg_match('/^(?:```|\||#|[-*] |<a |<!--)/', trim($lines[$i + 1]))) $paragraph .= ' ' . trim($lines[++$i]);
            $out .= '<p>' . inlineMarkdown($paragraph) . '</p>';
        }
    }
    return $out;
}
