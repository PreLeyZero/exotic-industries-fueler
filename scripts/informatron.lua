local model = {}

--====================================================================================================
--INFORMATRON
--====================================================================================================

remote.add_interface("exotic-industries-fueler-informatron", {
    informatron_menu = function(data)
      return model.menu(data.player_index)
    end,
    informatron_page_content = function(data)
      return model.page_content(data.page_name, data.player_index, data.element)
    end
})

--MENU
------------------------------------------------------------------------------------------------------

function model.menu(player_index)
    return info = 1
end

--CONTENT
------------------------------------------------------------------------------------------------------