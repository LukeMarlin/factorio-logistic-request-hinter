data:extend({
    {
        type = "string-setting",
        name = "logistic-request-hinter-ui-position",
        setting_type = "runtime-per-user",
        default_value = "top",
        allowed_values = {"top", "left"},
        order = "1"
    },
    {
        type = "int-setting",
        name = "logistic-request-hinter-column-count",
        setting_type = "runtime-per-user",
        default_value = 5,
        order = "2"
    },
    {
        type = "bool-setting",
        name = "logistic-request-hinter-show-frame-caption",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "3"
    }
})