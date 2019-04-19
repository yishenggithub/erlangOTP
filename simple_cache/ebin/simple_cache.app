{
    application, simple_cache,
    [
        {description, "A simple caching system"},
        {vsn, "0.3.0"},
        {modules, [
            sc_app,
            sc_sup,
            simple_cache,
            sc_element_sup,
            sc_store,
            sc_element,
            sc_event,
            sc_event_logger
            ]},
        {registered, [sc_sup]},
        {applications, [kernel, sasl, stdlib, mnesia, resource_discovery]},
        {mod, {sc_app, []}}
    ]
}.
