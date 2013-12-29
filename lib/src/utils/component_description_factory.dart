part of library;

/**
 * Define type for component factory ( function which return new instance of Component with props )
 */

typedef ComponentDescriptionInterface ComponentDescriptionFactory([PropsInterface props, List<ComponentDescriptionInterface> children]);