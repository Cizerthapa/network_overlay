# AssistiveTouchOverlay

`AssistiveTouchOverlay` is a reusable “Assistive Touch”-style floating bubble.

## Requirements

- Place it under a `Stack` (it uses `AnimatedPositioned`).

## Key parameters

- `builder`: builds the bubble UI. Receives a `pulseAnimation` that you can use with `ScaleTransition`.
- `bubbleSize`: used for snap/clamp calculations (defaults to `60`).
- `edgePadding`: snap/clamp padding (supports negative values to sit flush with the edge; defaults to `-20`).
- `initialPosition`: initial `Offset` (defaults to `Offset(edgePadding, 200)`).
- `isPulsing`: when `true`, `pulseAnimation` animates between `pulseBegin` and `pulseEnd`.

## Example

```dart
Stack(
  children: [
    const MyScreen(),
    AssistiveTouchOverlay(
      isPulsing: true,
      onTap: () => debugPrint('tap'),
      builder: (context, pulseAnimation) {
        return ScaleTransition(
          scale: pulseAnimation,
          child: const _MyBubble(),
        );
      },
    ),
  ],
);
```

