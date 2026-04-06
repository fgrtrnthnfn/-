local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"1c1c1c","MainTransparency":0,"AccentColor":"0055ff","AccentTransparency":0,"BackgroundColor":"141414","BackgroundTransparency":0,"OutlineColor":"323232","OutlineTransparency":0}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"1e1e1e","MainTransparency":0,"AccentColor":"7e48a3","AccentTransparency":0,"BackgroundColor":"232323","BackgroundTransparency":0,"OutlineColor":"141414","OutlineTransparency":0}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"1e1842","MainTransparency":0,"AccentColor":"c50754","AccentTransparency":0,"BackgroundColor":"191335","BackgroundTransparency":0,"OutlineColor":"3c355d","OutlineTransparency":0}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"242424","MainTransparency":0,"AccentColor":"db4467","AccentTransparency":0,"BackgroundColor":"1c1c1c","BackgroundTransparency":0,"OutlineColor":"373737","OutlineTransparency":0}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"242424","MainTransparency":0,"AccentColor":"3db488","AccentTransparency":0,"BackgroundColor":"1c1c1c","BackgroundTransparency":0,"OutlineColor":"373737","OutlineTransparency":0}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"191925","MainTransparency":0,"AccentColor":"6759b3","AccentTransparency":0,"BackgroundColor":"16161f","BackgroundTransparency":0,"OutlineColor":"323232","OutlineTransparency":0}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"3e3e3e","MainTransparency":0,"AccentColor":"e2581e","AccentTransparency":0,"BackgroundColor":"323232","BackgroundTransparency":0,"OutlineColor":"191919","OutlineTransparency":0}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","FontTransparency":0,"MainColor":"232330","MainTransparency":0,"AccentColor":"426e87","AccentTransparency":0,"BackgroundColor":"1d1b26","BackgroundTransparency":0,"OutlineColor":"27232f","OutlineTransparency":0}') },
	}

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		local scheme = data[2]
		local themeData = customThemeData or scheme
		
		-- Применяем цвета и прозрачности
		for idx, col in next, themeData do
			if idx:find('Transparency') then
				-- Это настройка прозрачности
				local colorName = idx:gsub('Transparency', '')
				if self.Library[colorName] and Options[colorName] then
					local transparency = tonumber(col) or 0
					Options[colorName].Transparency = transparency
					if Options[colorName].Display then
						Options[colorName]:Display()
					end
				end
			else
				-- Это цвет
				self.Library[idx] = Color3.fromHex(col)
				if Options[idx] then
					Options[idx]:SetValueRGB(Color3.fromHex(col))
					-- Восстанавливаем прозрачность для этого цвета
					local transKey = idx .. 'Transparency'
					if themeData[transKey] then
						Options[idx].Transparency = tonumber(themeData[transKey]) or 0
						if Options[idx].Display then
							Options[idx]:Display()
						end
					end
				end
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
				-- Обновляем прозрачность в библиотеке
				self.Library[field .. 'Transparency'] = Options[field].Transparency or 0
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		-- Цвета со слайдерами прозрачности
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor, Transparency = self.Library.BackgroundTransparency or 0 })
		groupbox:AddSlider('BackgroundTransparency', { Text = 'Background transparency', Default = self.Library.BackgroundTransparency or 0, Min = 0, Max = 1, Rounding = 2 })
		
		groupbox:AddLabel('Main color'):AddColorPicker('MainColor', { Default = self.Library.MainColor, Transparency = self.Library.MainTransparency or 0 })
		groupbox:AddSlider('MainTransparency', { Text = 'Main transparency', Default = self.Library.MainTransparency or 0, Min = 0, Max = 1, Rounding = 2 })
		
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor, Transparency = self.Library.AccentTransparency or 0 })
		groupbox:AddSlider('AccentTransparency', { Text = 'Accent transparency', Default = self.Library.AccentTransparency or 0, Min = 0, Max = 1, Rounding = 2 })
		
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor, Transparency = self.Library.OutlineTransparency or 0 })
		groupbox:AddSlider('OutlineTransparency', { Text = 'Outline transparency', Default = self.Library.OutlineTransparency or 0, Min = 0, Max = 1, Rounding = 2 })
		
		groupbox:AddLabel('Font color'):AddColorPicker('FontColor', { Default = self.Library.FontColor, Transparency = self.Library.FontTransparency or 0 })
		groupbox:AddSlider('FontTransparency', { Text = 'Font transparency', Default = self.Library.FontTransparency or 0, Min = 0, Max = 1, Rounding = 2 })

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		
		groupbox:AddButton('Save theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)

		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		-- Обновление при изменении цвета
		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
		
		-- Обновление при изменении прозрачности
		Options.BackgroundTransparency:OnChanged(UpdateTheme)
		Options.MainTransparency:OnChanged(UpdateTheme)
		Options.AccentTransparency:OnChanged(UpdateTheme)
		Options.OutlineTransparency:OnChanged(UpdateTheme)
		Options.FontTransparency:OnChanged(UpdateTheme)
		
		-- Синхронизация прозрачности с ColorPicker
		local function syncTransparency(colorOption, transOption)
			if colorOption and transOption then
				colorOption.OnChanged = colorOption.OnChanged or function() end
				local oldCallback = colorOption.Callback
				colorOption.Callback = function(color)
					if oldCallback then oldCallback(color) end
					transOption:SetValue(colorOption.Transparency or 0)
				end
			end
		end
		
		syncTransparency(Options.BackgroundColor, Options.BackgroundTransparency)
		syncTransparency(Options.MainColor, Options.MainTransparency)
		syncTransparency(Options.AccentColor, Options.AccentTransparency)
		syncTransparency(Options.OutlineColor, Options.OutlineTransparency)
		syncTransparency(Options.FontColor, Options.FontTransparency)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
			theme[field .. 'Transparency'] = Options[field].Transparency or 0
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
		self.Library:Notify(string.format('Theme "%s" saved', file))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		local parts = {}
		for part in self.Folder:gmatch('[^/]+') do
			table.insert(parts, part)
		end
		
		for idx = 1, #parts do
			local path = ''
			for i = 1, idx do
				if i > 1 then path = path .. '/' end
				path = path .. parts[i]
			end
			paths[#paths + 1] = path
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
