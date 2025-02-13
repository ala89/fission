# Fission

A state management and reactive UI framework for Roblox and Luau.

Fission enables easy UI scripting in a declarative style and simple state management leveraging reactive programming. High level primitives like `Tween` and `Persistent` allow to create beautiful animations for your game.

See the [documentation](https://soontm) for more details.

### Semantic guarantees

The sophisticated core algorithm addresses a number of issues identified in [Fusion](https://github.com/dphfox/Fusion) and otherwise linked to Luau's garbage collection engine. The behavior of Fission is exactly what you expect.

The most notable fix is the proper handling of dynamic state graph updates: Fission ensures that logical properties on the state graph remain true at all times, especially during updates.

It handles the addition of new nodes and edges, without violating the topological order condition on the evaluation of nodes. Likewise, it properly handles the deletion of nodes and immediately deactivates them when they fall out of scope, preventing unexpected errors from arising. This was made possible by introducing different types of dependencies.

Recursive updates are seamlessly supported, although we do not recommend to create update loops.

### Acknowledgements

This project was made to propose a fix to critical issues in the core algorithm of [Fusion](https://github.com/dphfox/Fusion) (see [here](https://github.com/dphfox/Fusion/issues/270) for more details). We stick to the API of Fusion v3 for compatibility reasons, with some additions.