# JanSharpsGuiLibrary
This library is _control stage only_, it provides:
* A ``gui-handler``
* Implementations for all ``basic`` types (such as "button" or "choose-elem-button")

The ``gui-handler`` uses a kind of **class system**. One can register classes, which one can then later create or
add as children to other instances.

Classes define how the ``LuaGuiElement`` will look, and which children and what style it should have.

The classes can very easily handle gui events. The ``basic`` class implementations even simplify handling events of nested children.

**Read the [wiki](https://github.com/JanSharp/JanSharpsGuiLibrary/wiki) for more information**
