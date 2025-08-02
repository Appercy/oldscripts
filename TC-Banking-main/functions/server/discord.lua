
Discord = {}

Discord.sendEmbed = function(title, description, fields)
    local embed = {
        title = title,
        description = description,
        fields = fields,
        author = {
            name = Config.WebhookName,
            icon_url = Config.WebhookLogo
        },
        footer = {
            icon_url = Config.WebhookLogo,
            text = os.date("%Y-%m-%d | %H:%M:%S")
        },
        color = 3447003
    }

    PerformHttpRequest(Config.Discord, function(err, response, body)
        if err == 0 then
            lib.print.debug("Discord webhook sent successfully.")
        else
            lib.print.error("Error sending discord webhook: " .. err)
        end
    end, "POST", json.encode({ embeds = { embed } }), { ["Content-Type"] = "application/json" })
end
return Discord