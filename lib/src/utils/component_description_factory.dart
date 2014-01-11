part of library;

/**
 * Define type for component factory ( function which return new instance of Component with props )
 */

typedef ComponentDescription ComponentDescriptionFactory([Props props, List<ComponentDescription> children]);