import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'calendar.dart';
import 'editors.dart';
import 'models.dart';
import 'overlays.dart';
import 'theme.dart';

class TxChat extends StatefulWidget {
  const TxChat({
    super.key,
    required this.user,
    this.items,
    this.onItemsChanged,
    this.controller,
    this.initialText = '',
    this.onInputFieldTextChanged,
    this.onMessageEntered,
    this.onMessageSent,
    this.onTypingStart,
    this.onTypingEnd,
    this.title = 'Chat',
    this.subtitle = '',
    this.label = 'Chat',
    this.placeholder = 'Nachricht schreiben …',
    this.emptyText = 'Noch keine Nachrichten. Starte die Unterhaltung.',
    this.disabled = false,
    this.readOnly = false,
    this.loading = false,
    this.sending = false,
    this.maxLength = 4000,
    this.typingUsers = const [],
    this.showAvatar = true,
    this.showUserName = true,
    this.showDayHeaders = true,
    this.showMessageTimestamp = true,
    this.locale = 'de',
    this.height = 560,
    this.header,
    this.empty,
    this.messageBuilder,
  }) : assert(maxLength > 0);
  final TxChatUser user;
  final List<TxChatMessage>? items;
  final ValueChanged<List<TxChatMessage>>? onItemsChanged;
  final TextEditingController? controller;
  final String initialText;
  final ValueChanged<String>? onInputFieldTextChanged;
  final ValueChanged<TxChange<TxChatMessage>>? onMessageEntered;
  final ValueChanged<TxChatMessage>? onMessageSent;
  final ValueChanged<TxChatUser>? onTypingStart, onTypingEnd;
  final String title, subtitle, label, placeholder, emptyText, locale;
  final bool disabled,
      readOnly,
      loading,
      sending,
      showAvatar,
      showUserName,
      showDayHeaders,
      showMessageTimestamp;
  final int maxLength;
  final List<TxChatUser> typingUsers;
  final double height;
  final Widget? header, empty;
  final Widget Function(
    BuildContext context,
    TxChatMessage message,
    bool isOwn,
  )?
  messageBuilder;
  @override
  State<TxChat> createState() => _TxChatState();
}

class _TxChatState extends State<TxChat> {
  late TextEditingController _text;
  final _scroll = ScrollController(), _inputFocus = FocusNode();
  List<TxChatMessage> _items = [];
  Set<Object> _knownKeys = {};
  Timer? _typingTimer;
  TxChatUser? _typingUser;
  int _counter = 0, _unread = 0;
  bool _atBottom = true;
  String? _error;
  List<TxChatMessage> get _source => widget.items ?? _items;
  bool get _blocked =>
      widget.disabled || widget.readOnly || widget.loading || widget.sending;
  bool get _canSend =>
      !_blocked &&
      _text.text.trim().isNotEmpty &&
      _text.text.length <= widget.maxLength;
  List<TxChatMessage> get _messages {
    txValidateKeys(_source, (item) => item.id);
    final indexed = _source.asMap().entries.toList()
      ..sort((a, b) {
        final result = a.value.timestamp.compareTo(b.value.timestamp);
        return result == 0 ? a.key.compareTo(b.key) : result;
      });
    return indexed.map((entry) => entry.value).toList();
  }

  @override
  void initState() {
    super.initState();
    _text =
        widget.controller ?? TextEditingController(text: widget.initialText);
    _text.addListener(_refresh);
    _scroll.addListener(_scrolled);
    _knownKeys = _source.map((item) => item.id).toSet();
    _toEnd();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _scrolled() {
    if (!_scroll.hasClients) return;
    final bottom = _scroll.position.maxScrollExtent - _scroll.offset < 48;
    if (_atBottom != bottom || bottom && _unread > 0) {
      setState(() {
        _atBottom = bottom;
        if (bottom) _unread = 0;
      });
    }
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      setState(() {
        _atBottom = true;
        _unread = 0;
      });
    });
  }

  void _endTyping() {
    _typingTimer?.cancel();
    _typingTimer = null;
    final user = _typingUser;
    _typingUser = null;
    if (user != null) widget.onTypingEnd?.call(user);
  }

  void _input(String value) {
    widget.onInputFieldTextChanged?.call(value);
    if (value.trim().isEmpty || _blocked) {
      _endTyping();
      return;
    }
    if (_typingUser == null) {
      _typingUser = widget.user;
      widget.onTypingStart?.call(widget.user);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), _endTyping);
    if (_error != null) setState(() => _error = null);
  }

  void _send() {
    if (!_canSend || !_text.value.composing.isCollapsed) return;
    Object id;
    do {
      id = 'tx-chat-${identityHashCode(this)}-${++_counter}';
    } while (_source.any((item) => item.id == id));
    final message = TxChatMessage(
      id: id,
      text: _text.text.trim(),
      timestamp: DateTime.now(),
      author: widget.user,
    );
    try {
      final event = TxChange(message);
      widget.onMessageEntered?.call(event);
      if (event.cancel) return;
      final next = [..._source, message];
      setState(() {
        _items = next;
        _error = null;
        _knownKeys = next.map((item) => item.id).toSet();
      });
      widget.onItemsChanged?.call(List.unmodifiable(next));
      _text.clear();
      widget.onInputFieldTextChanged?.call('');
      _endTyping();
      _toEnd();
      widget.onMessageSent?.call(message);
      _inputFocus.requestFocus();
    } catch (error) {
      setState(() => _error = '$error');
    }
  }

  @override
  void didUpdateWidget(TxChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final previous = _text.text;
      _text.removeListener(_refresh);
      if (oldWidget.controller == null) _text.dispose();
      _text = widget.controller ?? TextEditingController(text: previous);
      _text.addListener(_refresh);
    }
    if (_blocked || widget.user.id != oldWidget.user.id) _endTyping();
    final nextKeys = _source.map((item) => item.id).toSet(),
        added = _source.where((item) => !_knownKeys.contains(item.id)).length;
    _knownKeys = nextKeys;
    if (_atBottom) {
      _toEnd();
    } else {
      _unread += added;
    }
  }

  @override
  void dispose() {
    _endTyping();
    _text.removeListener(_refresh);
    if (widget.controller == null) _text.dispose();
    _scroll.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  String _date(DateTime date) =>
      DateFormat.yMMMMd(widget.locale).format(date.toLocal());
  String _time(DateTime date) =>
      DateFormat.Hm(widget.locale).format(date.toLocal());
  @override
  Widget build(BuildContext context) {
    final tokens = txThemeOf(context), messages = _messages;
    final typing = widget.typingUsers
        .where((user) => user.id != widget.user.id)
        .toList();
    return Semantics(
      label: widget.label,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            widget.header ??
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: tokens.hover,
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: tokens.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (widget.subtitle.isNotEmpty)
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  color: tokens.muted,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  ColoredBox(
                    color: tokens.surfaceAlt,
                    child: widget.loading
                        ? const Center(
                            child: TxLoadIndicator(
                              label: 'Nachrichten werden geladen …',
                            ),
                          )
                        : messages.isEmpty
                        ? Center(
                            child:
                                widget.empty ??
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    widget.emptyText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          )
                        : Semantics(
                            label: 'Nachrichtenverlauf',
                            liveRegion: true,
                            child: ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index],
                                    own = message.author.id == widget.user.id;
                                final initials = message.author.name
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .take(2)
                                    .map((part) => part.characters.first)
                                    .join()
                                    .toUpperCase();
                                final avatar = widget.showAvatar
                                    ? CircleAvatar(
                                        radius: 15,
                                        backgroundColor: tokens.hover,
                                        foregroundImage:
                                            message.author.avatarUrl == null
                                            ? null
                                            : NetworkImage(
                                                message.author.avatarUrl!,
                                              ),
                                        child: Text(
                                          initials,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      )
                                    : null;
                                return Column(
                                  children: [
                                    if (widget.showDayHeaders &&
                                        (index == 0 ||
                                            txDateKey(
                                                  messages[index - 1].timestamp
                                                      .toLocal(),
                                                ) !=
                                                txDateKey(
                                                  message.timestamp.toLocal(),
                                                )))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: Text(
                                          _date(message.timestamp),
                                          style: TextStyle(
                                            color: tokens.muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      key: ValueKey(message.id),
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Semantics(
                                        container: true,
                                        label:
                                            '${message.author.name}, ${_date(message.timestamp)} ${_time(message.timestamp)}',
                                        child: Row(
                                          mainAxisAlignment: own
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!own && avatar != null) ...[
                                              avatar,
                                              const SizedBox(width: 8),
                                            ],
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: own
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: [
                                                  if (widget.showUserName)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 4,
                                                          ),
                                                      child: Text(
                                                        message.author.name,
                                                        style: TextStyle(
                                                          color: tokens.muted,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: own
                                                          ? tokens.selection
                                                          : tokens.surface,
                                                      border: Border.all(
                                                        color:
                                                            message.status ==
                                                                TxMessageStatus
                                                                    .error
                                                            ? tokens.danger
                                                            : own
                                                            ? tokens.accent
                                                            : tokens.border,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child:
                                                        widget.messageBuilder
                                                            ?.call(
                                                              context,
                                                              message,
                                                              own,
                                                            ) ??
                                                        Text(message.text),
                                                  ),
                                                  Wrap(
                                                    spacing: 8,
                                                    children: [
                                                      if (widget
                                                          .showMessageTimestamp)
                                                        Text(
                                                          _time(
                                                            message.timestamp,
                                                          ),
                                                          style: TextStyle(
                                                            color: tokens.muted,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      if (own)
                                                        Text(
                                                          switch (message
                                                              .status) {
                                                            TxMessageStatus
                                                                .pending =>
                                                              'Wird gesendet',
                                                            TxMessageStatus
                                                                .sent =>
                                                              'Lokal gesendet',
                                                            TxMessageStatus
                                                                .error =>
                                                              'Senden fehlgeschlagen',
                                                          },
                                                          style: TextStyle(
                                                            color:
                                                                message.status ==
                                                                    TxMessageStatus
                                                                        .error
                                                                ? tokens.danger
                                                                : tokens.muted,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (own && avatar != null) ...[
                                              const SizedBox(width: 8),
                                              avatar,
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                  if (_unread > 0)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: TxButton(
                          text: '$_unread neue Nachrichten ↓',
                          onPressed: _toEnd,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    typing.isEmpty
                        ? ''
                        : '${typing.map((user) => user.name).join(', ')} ${typing.length == 1 ? 'schreibt' : 'schreiben'} …',
                    style: TextStyle(color: tokens.muted, fontSize: 11),
                  ),
                ),
              ),
            ),
            if (!widget.readOnly)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Focus(
                            onFocusChange: (focus) {
                              if (!focus) _endTyping();
                            },
                            onKeyEvent: (_, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.enter &&
                                  !HardwareKeyboard.instance.isShiftPressed &&
                                  _text.value.composing.isCollapsed) {
                                _send();
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextField(
                              controller: _text,
                              focusNode: _inputFocus,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: widget.maxLength,
                              enabled: !widget.disabled && !widget.loading,
                              decoration: InputDecoration(
                                labelText: 'Nachricht',
                                hintText: widget.placeholder,
                                counterText: '',
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              onChanged: _input,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TxButton(
                          text: widget.sending ? 'Wird gesendet …' : 'Senden ↑',
                          type: TxButtonType.primary,
                          disabled: !_canSend,
                          onPressed: _send,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Enter senden · Shift+Enter neue Zeile',
                            style: TextStyle(color: tokens.muted, fontSize: 9),
                          ),
                        ),
                        Text(
                          '${_text.text.length} / ${widget.maxLength}',
                          style: TextStyle(color: tokens.muted, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(_error!, style: TextStyle(color: tokens.danger)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
