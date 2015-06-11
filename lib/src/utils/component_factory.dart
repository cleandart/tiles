part of tiles;

/**
 * Define type for component factory (function which return new instance of Component with props)
 */

typedef Component ComponentFactory(
    {dynamic props, List<ComponentDescription> children});
