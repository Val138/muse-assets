-- shell and drawing proxy adapted from juju_fixed.txt, with muse branding.
-- ui controls, scrolling catalogues and configuration bridge are readable luau.
return function(ctx)
local drawing = ctx.Drawing
local LPH_NO_VIRTUALIZE = function(fn) return fn end
local udim2_new, vector2_new, color3_fromrgb = UDim2.new, Vector2.new, Color3.fromRGB
local view = workspace.CurrentCamera.ViewportSize
local menu_position = UDim2.fromOffset(math.max(10, (view.X - 620) / 2), math.max(10, (view.Y - 500) / 2))
local pixel_image_data = ctx.PixelBytes
local menu = {colors = {background=Color3.fromRGB(5,5,6), section=Color3.fromRGB(10,10,12), accent=Color3.fromRGB(225,225,229)}}
    local drawing_proxy = {}
    local create1 = (identifyexecutor() == "AWP" or identifyexecutor() == "Nihon") and Drawing["new"] or drawing["new"]

    drawing_proxy.new = (identifyexecutor() == "AWP" or identifyexecutor() == "Nihon") and LPH_NO_VIRTUALIZE(function(class, properties)
        local object = create1(class)

        local proxy = setmetatable({
            ["position"] = udim2_new(0, 0, 0, 0),
            ["real_position"] = vector2_new(0, 0),
            ["size"] = class == "Text" and 12 or udim2_new(0, 0, 0, 0),
            ["real_size"] = class == "Text" and 12 or vector2_new(0, 0),
            ["object"] = object,
            ["children"] = {},
            ["parent"] = false,
            ["is_rendering"] = false,
            ["skip"] = class == "Circle",
            ["visible"] = false,
            ["destroy"] = function()
                object:Destroy()
            end
        }, drawing_proxy)

        local size = properties["Size"]
        if size and type(size) == "number" then
            properties["Size"] = size+2
        end

        local z_index = properties["ZIndex"]
        properties["ZIndex"] = z_index and z_index+20 or 20

        for property, value in properties do
            proxy[property] = value
        end

        return proxy
    end) or LPH_NO_VIRTUALIZE(function(class, properties)
        local object = create1(class)

        local proxy = setmetatable({
            ["position"] = udim2_new(0, 0, 0, 0),
            ["real_position"] = vector2_new(0, 0),
            ["size"] = class == "Text" and 12 or udim2_new(0, 0, 0, 0),
            ["real_size"] = class == "Text" and 12 or vector2_new(0, 0),
            ["object"] = object,
            ["children"] = {},
            ["parent"] = false,
            ["is_rendering"] = false,
            ["skip"] = class == "Circle",
            ["visible"] = false,
            ["destroy"] = function()
                object:Destroy()
            end
        }, drawing_proxy)

        local z_index = properties["ZIndex"]
        properties["ZIndex"] = z_index and z_index+20 or 20

        for property, value in properties do
            proxy[property] = value
        end

        return proxy
    end)

    menu["create_proxy_drawing"] = drawing_proxy["new"]

    do
        local rawget = rawget
        local type = type

        local update_proxy_position
        update_proxy_position = LPH_NO_VIRTUALIZE(function(proxy, position)
            local parent = rawget(proxy, "parent")
            local real_position = parent and parent["real_position"] or vector2_new(position["X"]["Offset"], position["Y"]["Offset"])

            if parent then
                local parent_position = parent["real_position"]
                local real_parent_size = parent["real_size"]

                real_position = vector2_new((parent_position["X"] + real_parent_size["X"] * position["X"]["Scale"]) + position["X"]["Offset"], (parent_position["Y"] + real_parent_size["Y"] * position["Y"]["Scale"]) + position["Y"]["Offset"])
            end

            proxy["object"]["Position"] = real_position
            proxy["real_position"] = real_position

            local children = proxy["children"]
            for i = 1, #children do
                local child = children[i]
                update_proxy_position(child, child["position"])
            end
        end)

        local update_proxy_visibility
        update_proxy_visibility = LPH_NO_VIRTUALIZE(function(proxy, visible)
            local children = proxy["children"]
            local parent = rawget(proxy, "parent")
            local object = proxy["object"]

            if parent and not parent["is_rendering"] then
                proxy["is_rendering"] = false
                object["Visible"] = false
            else
                object["Visible"] = visible
                proxy["is_rendering"] = visible
            end

            for i = 1, #children do
                local child = children[i]
                update_proxy_visibility(child, child["visible"])
            end
        end)

        local update_proxy_size
        update_proxy_size = LPH_NO_VIRTUALIZE(function(proxy, size)
            if type(proxy) ~= "table" or type(proxy["real_size"]) == "number" then -- ??
                return
            end

            local parent = rawget(proxy, "parent")
            local real_size = parent and parent["real_size"] or vector2_new(size["X"]["Offset"], size["Y"]["Offset"])

            if parent then
                local parent_size = parent["real_size"]

                real_size = vector2_new((parent_size["X"] * size["X"]["Scale"]) + size["X"]["Offset"], (parent_size["Y"] * size["Y"]["Scale"]) + size["Y"]["Offset"])
            end

            proxy["object"]["Size"] = real_size
            proxy["real_size"] = real_size

            local children = proxy["children"]
            for i = 1, #children do
                local child = children[i]
                local old = child["real_size"]
                update_proxy_size(child, child["size"])
                
                update_proxy_position(child, child["position"])

            end
        end)

        function drawing_proxy:__newindex(property, value)
            if property == "Position" or property == "tween_position" then
                self["position"] = value
                update_proxy_position(self, value)
            elseif property == "Parent" then
                if value then
                    local children = value["children"]
                    children[#children+1] = self
                end

                self["parent"] = value
                update_proxy_position(self, self["position"])
                update_proxy_visibility(self, self["visible"])

                if type(self["size"]) ~= "number" and not self["skip"] then
                    update_proxy_size(self, self["size"])
                end
            elseif property == "Visible" then
                self["visible"] = value
                update_proxy_visibility(self, value)
            elseif (property == "Size" or property == "tween_size") and type(value) ~= "number" and not self["skip"] then
                self["size"] = value
                update_proxy_size(self, value)
            else
                self["object"][property] = value
            end
        end

        function drawing_proxy:__index(property)
            return property == "tween_size" and self["size"] or property == "tween_position" and self["position"] or property == "Destroy" and self["destroy"] or self["object"][property]
        end
    end

    local frame = drawing_proxy["new"]("Image", {
        ["Position"] = menu_position,
        ["Size"] = udim2_new(0, 620, 0, 500),
        ["Color"] = menu["colors"]["background"],
        ["Rounding"] = 4,
        ["Data"] = pixel_image_data,
        ["Transparency"] = 1,
        ["Visible"] = true
    })

    local inside = drawing_proxy["new"]("Image", {
        ["Position"] = udim2_new(0, 1, 0, 1),
        ["Size"] = udim2_new(1, -2, 1, -2),
        ["Color"] = menu["colors"]["section"],
        ["Rounding"] = 4,
        ["Data"] = pixel_image_data,
        ["Transparency"] = 1,
        ["Parent"] = frame,
        ["Visible"] = true
    })

    local logo = drawing_proxy["new"]("Image", {
        ["Color"] = menu["colors"]["accent"],
        ["Data"] = ctx.LogoBytes,
        ["Position"] = udim2_new(0, 14, 0, 16),
        ["Parent"] = inside,
        ["Size"] = udim2_new(0, 24, 0, 28),
        ["Visible"] = true,
        ["Transparency"] = 1
    })

    local juju_text = drawing_proxy["new"]("Text", {
        ["Font"] = 1,
        ["Color"] = color3_fromrgb(255, 255, 255),
        ["Text"] = "muse",
        ["Parent"] = logo,
        ["Position"] = udim2_new(1, 5, 0, 3),
        ["Size"] = 12,
        ["Visible"] = true,
        ["Transparency"] = 1
    })

    local build_text = drawing_proxy["new"]("Text", {
        ["Font"] = 1,
        ["Color"] = menu["colors"]["accent"],
        ["Text"] = "da hood",
        ["Parent"] = logo,
        ["Position"] = udim2_new(1, 5, 0, 19),
        ["Size"] = 12,
        ["Visible"] = true,
        ["Transparency"] = 1
    })

    local right_side = drawing_proxy["new"]("Square", {
        ["Parent"] = inside,
        ["Position"] = udim2_new(0, 101, 0, 0),
        ["Size"] = udim2_new(1, -101, 1, 0),
        ["Color"] = menu["colors"]["background"],
        ["Visible"] = true,
        ["Filled"] = true,
        ["Transparency"] = 1
    })

    local right_side_cover = drawing_proxy["new"]("Square", {
        ["Parent"] = inside,
        ["Position"] = udim2_new(0, 101, 0, 0),
        ["Size"] = udim2_new(1, -101, 1, 0),
        ["Color"] = menu["colors"]["background"],
        ["Visible"] = true,
        ["Filled"] = true,
        ["ZIndex"] = 999,
        ["Transparency"] = 0
    })

    local right_side_divider = drawing_proxy["new"]("Square", {
        ["Parent"] = inside,
        ["Position"] = udim2_new(0, 100, 0, 0),
        ["Size"] = udim2_new(0, 1, 1, 0),
        ["Color"] = menu["colors"]["background"],
        ["Visible"] = true,
        ["Thickness"] = 1,
        ["Filled"] = true,
        ["Transparency"] = 1
    })

local UI = {
    scr = drawing.sgui, alive = true, shown = true, pool = {}, wins = {}, tabs = {},
    quiet = false, configApplying = false, cursors = {}, cursorlist = {},
    theme = {accent=Color3.fromRGB(225,225,229), text=Color3.fromRGB(220,220,224),
        dim=Color3.fromRGB(110,110,117), bg=Color3.fromRGB(5,5,6), head=Color3.fromRGB(14,14,17),
        panel=Color3.fromRGB(8,8,10), line=Color3.fromRGB(52,55,59)},
    conns = {}, FrameRate = 0, rowMap = {}, rows = {}, options = {}, sections = {}, fits = {}, gates = {}, dependencies = {},
}
local function new(class, properties, parent)
    local object = Instance.new(class)
    for key,value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end
local function keep(connection)
    UI.conns[#UI.conns+1] = connection
    return connection
end
local function text(value) return string.lower(tostring(value or "")) end
local function label(parent, caption, size)
    return new("TextLabel", {BackgroundTransparency=1, BorderSizePixel=0, Text=text(caption),
        TextColor3=UI.theme.text, TextSize=size or 11, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,-8,1,0), ZIndex=40}, parent)
end
local function button(parent, caption)
    local object = new("TextButton", {Text=text(caption), TextSize=11, Font=Enum.Font.GothamMedium,
        TextColor3=UI.theme.text, BackgroundColor3=UI.theme.head, BorderSizePixel=0,
        AutoButtonColor=true, Size=UDim2.new(1,0,0,20), ZIndex=42}, parent)
    new("UICorner", {CornerRadius=UDim.new(0,3)}, object)
    new("UIStroke", {Color=UI.theme.line,Thickness=1,Transparency=0.45}, object)
    return object
end
local function layout(parent, spacing)
    return new("UIListLayout", {Padding=UDim.new(0,spacing or 5), SortOrder=Enum.SortOrder.LayoutOrder},parent)
end
-- Drawing proxies are siblings in the ScreenGui, not actual GuiObject parents.
-- A separate overlay keeps native controls above the opaque right-side drawing.
local function fitVertical(parent,list,padding)
    parent.AutomaticSize=Enum.AutomaticSize.None
    local function resize()
        if not UI.alive then return end
        local bounds=list.AbsoluteContentSize
        local height=math.max(0,(bounds and bounds.Y or 0)+(padding or 0))
        if parent.Size.Y.Offset~=height or parent.Size.Y.Scale~=0 then
            parent.Size=UDim2.new(parent.Size.X.Scale,parent.Size.X.Offset,0,height)
        end
    end
    keep(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize))
    UI.fits[#UI.fits+1]=resize;resize()
end
local shellInside = inside.object.__OBJECT
local nativeRoot = new("Frame", {Name="MuseNativeOverlay",BackgroundTransparency=1,
    BorderSizePixel=0,ZIndex=50},drawing.sgui)
local function syncOverlay()
    nativeRoot.Position=shellInside.Position
    nativeRoot.Size=shellInside.Size
end
keep(shellInside:GetPropertyChangedSignal("Position"):Connect(syncOverlay))
keep(shellInside:GetPropertyChangedSignal("Size"):Connect(syncOverlay))
syncOverlay()
local content = new("Frame", {Name="MusePages",BackgroundTransparency=1,
    Position=UDim2.fromOffset(108,12), Size=UDim2.new(1,-121,1,-24), ZIndex=35}, nativeRoot)
frame.Visible = true
inside.Visible = true
UI.shell, UI.root, UI.logo = frame.object.__OBJECT, content, logo.object.__OBJECT
local dragging, dragStart, originalPosition
local dragHandle = new("TextButton", {Name="MuseDrag",Text="",BackgroundTransparency=1,
    Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(101,64),ZIndex=45},nativeRoot)
keep(dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true;dragStart=input.Position;originalPosition=frame.position
    end
end))
keep(game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-dragStart
        frame.Position=originalPosition+UDim2.fromOffset(delta.X,delta.Y)
    end
end))
keep(game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end))

function UI:render(value)
    self.shown=value==true
    frame.Visible=self.shown
    nativeRoot.Visible=self.shown
    content.Visible=self.shown
    if not self.shown then self:closepopup() end
    if self.shown and self.ActiveTab then
        for _,gallery in ipairs(self.ActiveTab.galleries) do gallery:refresh() end
    end
    if self.onRender then self.onRender(self.shown) end
end
function UI:chime() end
function UI:recolor(key,color) self.theme[key]=color end
function UI:hook(flag,kind,get,set)
    if flag then self.pool[flag]={kind=kind,get=get,set=set} end
end
function UI:notify(config)
    if ctx.Notify then ctx.Notify(config.content or config.Content or config.title or "",config.duration or 4) end
end

local binding
keep(game:GetService("UserInputService").InputBegan:Connect(function(input,processed)
    if binding then
        local key=input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
        if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.Backspace then key=nil end
        local entry=binding;binding=nil;entry.set(entry,key)
        task.defer(function() UI.capturing=false end)
        return
    end
    if not processed and UI.MenuKey and (input.KeyCode==UI.MenuKey or input.UserInputType==UI.MenuKey) then
        UI:render(not UI.shown)
    end
end))

local Section = {}
Section.__index=Section
function Section:SetVisible(value) self.Root.Visible=value==true end
function Section:SetFeature(flag) self.FeatureFlag=flag end
function Section:row(caption,height)
    local row=new("Frame",{Name="MuseControl",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,height or 18),ZIndex=40},self.items)
    self.__sec.n=(self.__sec.n or 0)+2
    row.LayoutOrder=self.__sec.n
    local meta={Root=row,Size=row.Size,Section=self,Members={}}
    UI.rowMap[row]=meta;UI.rows[#UI.rows+1]=meta
    return row,label(row,caption)
end
local function entry(section,row,widget,flag,kind,initial,callback)
    local value=initial
    local control={__el={row=row}, row=row, Root=row, widget=widget,Flag=flag}
    local meta=UI.rowMap[row]
    if meta then meta.Members[#meta.Members+1]=control end
    function control:get() return value end
    function control:GetValue() return value end
    function control:set(v,silent)
        value=v
        if self.paint then self.paint(v) end
        if callback then callback(v) end
        if UI.RefreshCompact and not UI.configApplying then UI:RefreshCompact() end
        if not silent and not UI.quiet then UI:chime(v==false and "off" or "on") end
    end
    function control:SetValue(v) self:set(v,true) end
    function control:Set(v) self:set(v,true) end
    function control:SetVisible(v) row.Visible=v==true end
    control.__el.get=function() return value end
    control.__el.set=function(_,v) control:set(v,true) end
    UI:hook(flag,kind,function() return value end,function(v) control:set(v,true) end)
    if ctx.Register then ctx.Register(flag,control) end
    return control
end
function Section:AddLabel(caption,status)
    local section=self
    local row={Name=caption}
    if status then
        local root,body=section:row(caption)
        row.Root=root
        function row:SetText(v) body.Text=text(v) end
        return row
    end
    function row:AddToggle(cfg)
        cfg=cfg or {}
        local root,body=section:row(caption)
        row.Root,row.Body=root,body
        body.Position=UDim2.fromOffset(18,0);body.Size=UDim2.new(1,-45,1,0)
        local box=button(root,"");box.Size=UDim2.fromOffset(11,11);box.Position=UDim2.fromOffset(0,3)
        new("UIStroke",{Color=UI.theme.line,Thickness=1},box)
        local control=entry(section,root,box,cfg.Flag,"boolean",cfg.Default==true,cfg.Callback)
        control.paint=function(v)
            box.Text=""
            box.BackgroundColor3=v and UI.theme.accent or UI.theme.panel
            body.TextColor3=v and UI.theme.text or UI.theme.dim
        end
        control.paint(cfg.Default==true)
        keep(box.Activated:Connect(function() control:set(not control:get()) end))
        row.toggle=control
        return control
    end
    function row:AddKeybind(cfg)
        cfg=cfg or {}
        if row.toggle then return row:AddOption():AddLabel("keybind"):AddKeybind(cfg) end
        local root,body=section:row(caption)
        body.Size=UDim2.new(0.55,0,1,0)
        local box=button(root,"none");box.Position=UDim2.new(0.57,0,0,0);box.Size=UDim2.new(0.43,0,0,18)
        row.Root,row.Body=root,body
        local control=entry(section,root,box,cfg.Flag,"enum",nil,function(v)
            if cfg.Callback then cfg.Callback(typeof(v)=="EnumItem" and v.Name or v) end
        end)
        row.keybind=control
        control.paint=function(v) box.Text=v and text(typeof(v)=="EnumItem" and v.Name or v) or "none" end
        keep(box.Activated:Connect(function() binding=control;UI.capturing=true;box.Text="..." end))
        return control
    end
    function row:AddSlider(cfg)
        cfg=cfg or {}
        if row.toggle then return row:AddOption():AddLabel(cfg.Name or "amount"):AddSlider(cfg) end
        local root,body=section:row(caption,28)
        body.Size=UDim2.new(0.65,0,0,15)
        local valueLabel=label(root,"");valueLabel.Position=UDim2.new(0.65,0,0,0)
        valueLabel.Size=UDim2.new(0.35,0,0,15);valueLabel.TextXAlignment=Enum.TextXAlignment.Right
        local track=button(root,"");track.Position=UDim2.fromOffset(0,20);track.Size=UDim2.new(1,0,0,6)
        local fill=new("Frame",{BackgroundColor3=UI.theme.accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),ZIndex=43},track)
        local minimum,maximum=cfg.Min or 0,cfg.Max or 100
        local step=10^-(cfg.Rounding or 0)
        local control=entry(section,root,track,cfg.Flag,"number",cfg.Default or minimum,cfg.Callback)
        control.paint=function(v)
            v=math.clamp(tonumber(v) or minimum,minimum,maximum)
            valueLabel.Text=tostring(v)..(cfg.Type or "")
            fill.Size=UDim2.new((v-minimum)/math.max(maximum-minimum,0.001),0,1,0)
        end
        control.paint(control:get())
        local adjusting=false
        local dragLeft,dragWidth,dragRatio
        local valuePaint=control.paint
        local thumb=new("Frame",{Name="SliderThumb",AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=UI.theme.accent,BorderSizePixel=0,Size=UDim2.fromOffset(7,9),ZIndex=44},track)
        new("UICorner",{CornerRadius=UDim.new(0,2)},thumb)
        control.paint=function(v)
            valuePaint(v)
            local ratio=adjusting and dragRatio or math.clamp(((tonumber(v) or minimum)-minimum)/math.max(maximum-minimum,0.001),0,1)
            fill.Size=UDim2.new(ratio or 0,0,1,0)
            thumb.Position=UDim2.new(ratio or 0,0,0.5,0)
        end
        control.paint(control:get())
        local function adjust(event)
            -- InputObject.Position belongs to this mouse event; polling can lag behind it.
            local x=event and event.Position and event.Position.X or game:GetService("UserInputService"):GetMouseLocation().X
            dragRatio=math.clamp((x-dragLeft)/dragWidth,0,1)
            fill.Size=UDim2.new(dragRatio,0,1,0);thumb.Position=UDim2.new(dragRatio,0,0.5,0)
            local nextValue=math.clamp(math.floor((minimum+(maximum-minimum)*dragRatio)/step+0.5)*step,minimum,maximum)
            -- Draw continuously, while callbacks receive only changed rounded values.
            if nextValue~=control:get() then control:set(nextValue,true) end
        end
        keep(track.InputBegan:Connect(function(event)
            if event.UserInputType==Enum.UserInputType.MouseButton1 then
                dragLeft=track.AbsolutePosition.X;dragWidth=math.max(track.AbsoluteSize.X,1)
                dragRatio=math.clamp(((tonumber(control:get()) or minimum)-minimum)/math.max(maximum-minimum,0.001),0,1)
                adjusting=true;adjust(event)
            end
        end))
        keep(game:GetService("UserInputService").InputChanged:Connect(function(event)
            if adjusting and event.UserInputType==Enum.UserInputType.MouseMovement then adjust(event) end
        end))
        keep(game:GetService("UserInputService").InputEnded:Connect(function(event)
            if adjusting and event.UserInputType==Enum.UserInputType.MouseButton1 then
                adjust(event);adjusting=false;control.paint(control:get())
            end
        end))
        return control
    end
    function row:AddDropdown(cfg)
        cfg=cfg or {}
        if row.toggle then return row:AddOption():AddLabel(cfg.Name or "mode"):AddDropdown(cfg) end
        local root,body=section:row(caption,34);body.Size=UDim2.new(1,0,0,14)
        local box=button(root,"");box.Position=UDim2.fromOffset(0,15)
        local choices=cfg.Values or {}
        local initial=cfg.Default
        if cfg.Multi and type(initial)~="table" then initial={} end
        if initial==nil then initial=choices[1] end
        local control=entry(section,root,box,cfg.Flag,cfg.Multi and "table" or "string",initial,cfg.Callback)
        control.paint=function(v)
            if type(v)=="table" then
                local names={}
                for k,item in pairs(v) do names[#names+1]=type(k)=="string" and item==true and k or tostring(item) end
                table.sort(names);box.Text=#names>0 and text(table.concat(names,", ")) or "none"
            else box.Text=text(v or "none") end
        end
        control.paint(initial)
        function control:SetValues(v) choices=v end
        function control:Generate() end
        control.__el.setlist=function(_,v) choices=v end
        keep(box.Activated:Connect(function()
            UI:popup({owner=box,title=caption,items=(function()
                local items={}
                for _,choice in ipairs(choices) do
                    items[#items+1]={name=choice,callback=function()
                        if cfg.Multi then
                            local selected=table.clone(type(control:get())=="table" and control:get() or {})
                            selected[choice]=not selected[choice] or nil;control:set(selected)
                        else control:set(choice) end
                    end}
                end
                return items
            end)()})
        end))
        return control
    end
    function row:AddColorPicker(cfg)
        cfg=cfg or {}
        local root,body
        if row.toggle then root,body=row.Root,row.Body else root,body=section:row(caption) end
        body.Size=UDim2.new(1,-55,1,0)
        local box=button(root,"");box.Position=UDim2.new(1,row.gear and -46 or -24,0,3);box.Size=UDim2.fromOffset(21,11)
        row.colorBox=box
        local control=entry(section,root,box,cfg.Flag,"color",cfg.Default or Color3.new(1,1,1),cfg.Callback)
        control.paint=function(v) if typeof(v)=="Color3" then box.BackgroundColor3=v end end
        control.paint(control:get())
        keep(box.Activated:Connect(function()
            UI:colorpopup(control,caption,box)
        end))
        return control
    end
    function row:AddTextInput(cfg)
        cfg=cfg or {}
        local root=section:row("",29)
        local box=new("TextBox",{Text=cfg.Default or "",PlaceholderText=text(cfg.Placeholder or caption),
            BackgroundColor3=UI.theme.head,TextColor3=UI.theme.text,TextSize=12,Font=Enum.Font.GothamMedium,
            BorderSizePixel=0,ClearTextOnFocus=false,Size=UDim2.new(1,0,1,-3),ZIndex=43},root)
        local control=entry(section,root,box,cfg.Flag,"string",cfg.Default or "",cfg.Callback)
        control.paint=function(v) box.Text=tostring(v or "") end
        keep(box.FocusLost:Connect(function() control:set(box.Text) end))
        return control
    end
    function row:AddOption()
        if row.options then return row.options end
        if not row.Root then row.Root,row.Body=section:row(caption) end
        local root=new("Frame",{Name="MuseFeatureOptions",BackgroundColor3=UI.theme.head,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Visible=false,
            LayoutOrder=row.Root.LayoutOrder+1},section.items)
        new("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,7),PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5)},root)
        local optionLayout=layout(root,2);fitVertical(root,optionLayout,10)
        row.options=setmetatable({Root=root,Items=root,items=root,__sec={items=root,n=0}},Section)
        local gear=button(row.Root,"\u{2699}")
        gear.Name="MuseOptionsButton";gear.BackgroundTransparency=1
        gear.Position=UDim2.new(1,-17,0,0);gear.Size=UDim2.fromOffset(17,18)
        row.gear=gear
        UI.options[#UI.options+1]={Owner=row,Root=root,Section=section}
        if row.keybind then row.keybind.widget.Size=UDim2.new(0.43,-22,0,18) end
        if row.colorBox then row.colorBox.Position=UDim2.new(1,-46,0,3) end
        keep(gear.Activated:Connect(function()
            UI:closepopup()
            if UI.compactInstalled then
                if row.optionActive then row.optionManual=not root.Visible end
                UI:RefreshCompact()
            else root.Visible=not root.Visible;gear.Text=root.Visible and "-" or "\u{2699}" end
        end))
        return row.options
    end
    function row:SetText(v) self.Name=v end
    return row
end
function Section:AddButton(cfg)
    local root=self:row("",27)
    local box=button(root,cfg.Name or "button")
    keep(box.Activated:Connect(function() if cfg.Callback then cfg.Callback() end;UI:chime("on") end))
    return {__el={row=root},Root=root}
end

-- One shared HSV wheel popup serves every color control. No frame-loop work.
function UI.colorToHex(color)
    return string.format("#%02X%02X%02X",math.floor(color.R*255+0.5),math.floor(color.G*255+0.5),math.floor(color.B*255+0.5))
end
function UI.colorFromHex(value)
    local hex=tostring(value or ""):match("^%s*#?(%x%x%x%x%x%x)%s*$")
    if not hex then return nil end
    return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))
end
function UI.wheelHSV(dx,dy,radius)
    return (math.atan2(dx,-dy)/(2*math.pi))%1,math.clamp(math.sqrt(dx*dx+dy*dy)/math.max(radius,1),0,1)
end
function UI:colorpopup(control,title,anchor)
    if not self:beginpopup(anchor) then return nil end
    local width,height=232,275
    local view=workspace.CurrentCamera.ViewportSize
    local x,y=self:popupPosition(anchor,width,height)
    local root=new("Frame",{Name="MuseColorPicker",BackgroundColor3=self.theme.panel,BorderSizePixel=0,
        Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),ZIndex=1100},self.scr)
    new("UICorner",{CornerRadius=UDim.new(0,4)},root)
    new("UIStroke",{Color=self.theme.line,Thickness=1},root)
    self.popupRoot=root
    local connections={}
    local function connect(signal,callback) connections[#connections+1]=signal:Connect(callback) end
    local heading=label(root,title);heading.Position=UDim2.fromOffset(12,7);heading.Size=UDim2.fromOffset(175,17)
    local close=button(root,"x");close.Position=UDim2.new(1,-26,0,6);close.Size=UDim2.fromOffset(18,18)
    connect(close.Activated,function() self:closepopup() end)
    local wheel=new("ImageButton",{Name="ColorWheel",BackgroundTransparency=1,BorderSizePixel=0,
        AutoButtonColor=false,Position=UDim2.fromOffset(12,33),Size=UDim2.fromOffset(176,176),ZIndex=1101},root)
    local marker=new("Frame",{Name="WheelMarker",AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,Size=UDim2.fromOffset(8,8),ZIndex=1102},wheel)
    new("UICorner",{CornerRadius=UDim.new(1,0)},marker)
    new("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},marker)
    local brightness=new("TextButton",{Name="Brightness",Text="",AutoButtonColor=false,BorderSizePixel=0,
        BackgroundColor3=Color3.new(1,1,1),Position=UDim2.fromOffset(202,33),Size=UDim2.fromOffset(14,176),ZIndex=1101},root)
    local gradient=new("UIGradient",{Rotation=90},brightness)
    new("UIStroke",{Color=self.theme.line,Thickness=1},brightness)
    local valueMarker=new("Frame",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,Size=UDim2.new(1,4,0,3),Position=UDim2.fromOffset(-2,0),ZIndex=1102},brightness)
    new("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},valueMarker)
    local preview=new("Frame",{Name="ColorPreview",BorderSizePixel=0,Position=UDim2.fromOffset(12,222),Size=UDim2.fromOffset(22,23)},root)
    new("UIStroke",{Color=self.theme.line,Thickness=1},preview)
    local hex=new("TextBox",{Name="HexColor",Text="",PlaceholderText="#rrggbb",ClearTextOnFocus=false,
        TextColor3=self.theme.text,BackgroundColor3=self.theme.head,BorderSizePixel=0,Font=Enum.Font.Code,
        TextSize=12,Position=UDim2.fromOffset(42,222),Size=UDim2.fromOffset(128,23)},root)
    new("UIStroke",{Color=self.theme.line,Thickness=1},hex)
    local copy=button(root,"copy");copy.Position=UDim2.fromOffset(176,222);copy.Size=UDim2.fromOffset(44,23)
    local hint=label(root,"hex | paste to import");hint.TextColor3=self.theme.dim
    hint.Position=UDim2.fromOffset(12,250);hint.Size=UDim2.fromOffset(210,15)
    local hue,saturation,value=control:get():ToHSV()
    local basePaint=control.paint
    local adjustingColor=false
    local function paint(color)
        if not adjustingColor then hue,saturation,value=color:ToHSV() end
        local angle=hue*2*math.pi
        marker.Position=UDim2.fromScale(0.5+math.sin(angle)*saturation*0.5,0.5-math.cos(angle)*saturation*0.5)
        wheel.ImageColor3=Color3.new(value,value,value)
        gradient.Color=ColorSequence.new(Color3.fromHSV(hue,saturation,1),Color3.new(0,0,0))
        valueMarker.Position=UDim2.new(0,-2,1-value,0)
        preview.BackgroundColor3=color;hex.Text=UI.colorToHex(color);hex.TextColor3=self.theme.text
    end
    control.paint=function(color)
        if basePaint then basePaint(color) end
        if self.popupRoot==root then paint(color) end
    end
    paint(control:get())
    local dragging
    local function update(kind,event)
        if self.popupRoot~=root then return end
        local mouse=event and event.Position or game:GetService("UserInputService"):GetMouseLocation()
        if kind=="wheel" then
            local size=wheel.AbsoluteSize;local position=wheel.AbsolutePosition
            local dx,dy=mouse.X-position.X-size.X/2,mouse.Y-position.Y-size.Y/2
            hue,saturation=UI.wheelHSV(dx,dy,math.min(size.X,size.Y)/2)
        else value=1-math.clamp((mouse.Y-brightness.AbsolutePosition.Y)/math.max(brightness.AbsoluteSize.Y,1),0,1) end
        adjustingColor=true
        control:set(Color3.fromHSV(hue,saturation,value),true)
        adjustingColor=false
    end
    connect(wheel.InputBegan,function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local mouse=input.Position or game:GetService("UserInputService"):GetMouseLocation()
        local dx,dy=mouse.X-wheel.AbsolutePosition.X-wheel.AbsoluteSize.X/2,mouse.Y-wheel.AbsolutePosition.Y-wheel.AbsoluteSize.Y/2
        if dx*dx+dy*dy>(wheel.AbsoluteSize.X/2)^2 then return end
        dragging="wheel";update(dragging,input)
    end)
    connect(brightness.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging="value";update(dragging,input) end
    end)
    local input=game:GetService("UserInputService")
    connect(input.InputChanged,function(event)
        if dragging and event.UserInputType==Enum.UserInputType.MouseMovement then update(dragging,event) end
    end)
    connect(input.InputEnded,function(event) if event.UserInputType==Enum.UserInputType.MouseButton1 then dragging=nil end end)
    connect(hex.FocusLost,function()
        local parsed=UI.colorFromHex(hex.Text)
        if parsed then hint.Text="hex | paste to import";control:set(parsed) else hex.Text=UI.colorToHex(control:get());hint.Text="use a six-digit hex color" end
    end)
    connect(copy.Activated,function()
        local copyText=UI.colorToHex(control:get())
        if setclipboard then setclipboard(copyText);hint.Text="hex copied"
        else hex:CaptureFocus();hex.SelectionStart=1;hex.CursorPosition=#hex.Text+1 end
    end)
    self.popupCleanup=function()
        dragging=nil;control.paint=basePaint
        for _,connection in ipairs(connections) do connection:Disconnect() end
    end
    task.spawn(function()
        local ok,asset=pcall(function() return ctx.Image and ctx.Image("images/color-wheel.png") end)
        if self.popupRoot~=root then return end
        if ok and type(asset)=="string" and asset~="" then wheel.Image=asset
        else hint.Text="wheel unavailable | use hex" end
    end)
    return {Root=root,Wheel=wheel,Hex=hex,Brightness=brightness,Copy=copy}
end

function UI:closepopup()
    if self.popupCleanup then local cleanup=self.popupCleanup;self.popupCleanup=nil;cleanup() end
    if self.popupRoot then self.popupRoot:Destroy();self.popupRoot=nil end
    self.popupOwner=nil
end
function UI:beginpopup(owner)
    if owner and self.popupRoot and self.popupOwner==owner then self:closepopup();return false end
    self:closepopup();self.popupOwner=owner;return true
end
function UI:popupPosition(anchor,width,height)
    local view=workspace.CurrentCamera.ViewportSize
    local origin=nativeRoot.AbsolutePosition-Vector2.new(nativeRoot.Position.X.Offset,nativeRoot.Position.Y.Offset)
    local left,top=anchor.AbsolutePosition.X-origin.X,anchor.AbsolutePosition.Y-origin.Y
    local x=math.clamp(left,8,math.max(8,view.X-width-8))
    local y=top+anchor.AbsoluteSize.Y+6
    if y+height>view.Y-8 then y=top-height-6 end
    return x,math.clamp(y,8,math.max(8,view.Y-height-8))
end
function UI:popup(cfg)
    local owner=cfg.owner or cfg.follow or cfg.name or cfg.title
    if not self:beginpopup(owner) then return nil end
    local mouse=game:GetService("UserInputService"):GetMouseLocation()
    local width,height=cfg.width or 185,math.min(320,38+#(cfg.items or {})*29)
    local x,y=cfg.x or mouse.X,cfg.y or mouse.Y
    if typeof(owner)=="Instance" and owner:IsA("GuiObject") then x,y=self:popupPosition(owner,width,height) end
    local root=new("ScrollingFrame",{BackgroundColor3=self.theme.panel,BorderSizePixel=0,
        Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=3,ZIndex=1000},self.scr)
    new("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7),PaddingTop=UDim.new(0,7)},root)
    layout(root,3)
    self.popupRoot=root
    local connections={}
    self.popupCleanup=function() for _,connection in ipairs(connections) do connection:Disconnect() end end
    local popup=setmetatable({Root=root,Items=root,items=root,__sec={items=root}},Section)
    popup:AddLabel(cfg.title or "options",true)
    for _,item in ipairs(cfg.items or {}) do
        local box=button(root,item.name)
        box.ZIndex=1001
        connections[#connections+1]=box.Activated:Connect(function() self:closepopup();if item.callback then item.callback() end end)
    end
    return popup
end
function UI:ask(cfg)
    return self:popup({title=cfg.title or cfg.name,items={{name="confirm",callback=cfg.callback or cfg.confirm},{name="cancel"}}})
end
function UI:closeask() self:closepopup() end

function UI:tab(name)
    local page={Name=name,sections={},galleries={}}
    local index=#self.tabs+1
    local tabButton=button(nativeRoot,name)
    tabButton.Position=UDim2.fromOffset(12,75+(index-1)*26);tabButton.Size=UDim2.fromOffset(81,22)
    tabButton.BackgroundTransparency=1;tabButton.TextXAlignment=Enum.TextXAlignment.Left
    local root=new("Frame",{Name="MuseTab_"..text(name),BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false},content)
    page.Root=root
    page.columns={}
    for _,side in ipairs({"left","right","full"}) do
        local column=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
            Position=side=="right" and UDim2.new(0.5,5,0,0) or UDim2.new(),
            Size=side=="full" and UDim2.fromScale(1,1) or UDim2.new(0.5,-5,1,0),
            ScrollBarThickness=1,ScrollBarImageColor3=UI.theme.dim,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=side~="full",ZIndex=40},root)
        new("UIPadding",{PaddingTop=UDim.new(0,6),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,3)},column)
        layout(column,12);page.columns[side]=column
    end
    local changed=Instance.new("BindableEvent")
    page.Signal={GetValue=function() return root.Visible end,Connect=function(_,fn) return keep(changed.Event:Connect(fn)) end}
    function page:select()
        UI:closepopup()
        for _,other in ipairs(UI.tabs) do
            local selected=other==self
            other.Root.Visible=selected
            other.button.TextColor3=selected and UI.theme.text or UI.theme.dim
            other.changed:Fire(selected)
            if selected then for _,gallery in ipairs(other.galleries) do gallery:refresh() end end
        end
        UI.ActiveTab=self
    end
    page.button,page.changed=tabButton,changed
    keep(tabButton.Activated:Connect(function() page:select();UI:chime("on") end))
    function page:AddSection(cfg)
        local side=cfg.Position or cfg.side or "left"
        if side=="full" then self.columns.left.Visible=false;self.columns.right.Visible=false;self.columns.full.Visible=true end
        local panel=new("Frame",{Name="MuseSection_"..text(cfg.Name or cfg.name),BackgroundColor3=UI.theme.panel,
            BorderSizePixel=0,Size=UDim2.new(1,-3,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=#self.sections+1,ZIndex=40},self.columns[side])
        local panelLayout=layout(panel,3)
        new("UIStroke",{Color=UI.theme.line,Thickness=1,Transparency=0.25},panel)
        new("UICorner",{CornerRadius=UDim.new(0,3)},panel)
        new("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,8)},panel)
        local title=new("Frame",{BackgroundTransparency=1,LayoutOrder=-1,Size=UDim2.new(1,0,0,14),ZIndex=40},panel)
        local heading=label(title,cfg.Name or cfg.name)
        heading.TextColor3=UI.theme.dim;heading.TextSize=11
        local items=new("Frame",{BackgroundTransparency=1,LayoutOrder=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=40},panel)
        local itemLayout=layout(items,2);fitVertical(items,itemLayout,0);fitVertical(panel,panelLayout,13)
        local section=setmetatable({Root=panel,Items=items,items=items,__sec={items=items,panel=panel,header=title,n=0}},Section)
        self.sections[#self.sections+1]=section
        UI.sections[#UI.sections+1]=section
        return section
    end
    function page:section(cfg) return self:AddSection({Name=cfg.name,Position=cfg.side}) end
    page.__sub=page
    page.SetValue=function(value) if value then page:select() end end
    function page:AddGallery(cfg) return UI:gallery(self,cfg) end
    UI.tabs[#UI.tabs+1]=page
    if index==1 then page:select() end
    return page
end

function UI:gallery(page,cfg)
    local section=cfg.Parent or page:AddSection({Name=cfg.Name,Position=cfg.Position or "right"})
    local search=new("TextBox",{Text="",PlaceholderText="search",BackgroundColor3=UI.theme.head,
        TextColor3=UI.theme.text,TextSize=11,Font=Enum.Font.GothamMedium,ClearTextOnFocus=false,
        BorderSizePixel=0,Size=UDim2.new(1,0,0,23),ZIndex=42},section.items)
    section.__sec.n=(section.__sec.n or 0)+2;search.LayoutOrder=section.__sec.n
    section.__sec.n=section.__sec.n+2
    local scroller=new("ScrollingFrame",{LayoutOrder=section.__sec.n,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,cfg.Height or 260),CanvasSize=UDim2.new(),ScrollBarThickness=2,ZIndex=42},section.items)
    local empty=label(scroller,cfg.Empty or "nothing here");empty.TextXAlignment=Enum.TextXAlignment.Center
    local gallery={data=cfg.Values or {},selected=cfg.Multi and {} or nil,cells={},filtered={},Root=section.Root}
    local rowHeight=(cfg.Cell or 80)+26
    function gallery:refresh()
        if not page.Root.Visible or not UI.shown then return end
        local columns=math.max(1,math.floor(scroller.AbsoluteSize.X/((cfg.Cell or 80)+6)))
        local width=math.floor((scroller.AbsoluteSize.X-(columns-1)*5)/columns)
        local first=math.floor(scroller.CanvasPosition.Y/rowHeight)*columns+1
        local capacity=(math.ceil(scroller.AbsoluteSize.Y/rowHeight)+1)*columns
        scroller.CanvasSize=UDim2.fromOffset(0,math.ceil(#self.filtered/columns)*rowHeight)
        empty.Visible=#self.filtered==0
        for slot=1,capacity do
            local item=self.filtered[first+slot-1]
            local cell=self.cells[slot]
            if not cell then
                local box=button(scroller,"");box.ZIndex=43
                local image=new("ImageLabel",{Active=false,Selectable=false,BackgroundTransparency=1,Size=UDim2.new(1,-6,1,-27),Position=UDim2.fromOffset(3,1),ScaleType=Enum.ScaleType.Fit,ZIndex=44},box)
                local viewport=new("ViewportFrame",{Active=false,Selectable=false,BackgroundTransparency=1,Size=image.Size,Position=image.Position,
                    Ambient=Color3.fromRGB(200,200,200),LightColor=Color3.new(1,1,1),Visible=false,ZIndex=44},box)
                local caption=label(box,"");caption.ZIndex=45;caption.Position=UDim2.new(0,4,1,-25);caption.Size=UDim2.new(1,-8,0,24)
                caption.TextSize=10;caption.TextTruncate=Enum.TextTruncate.AtEnd
                local stroke=new("UIStroke",{Color=UI.theme.line,Thickness=1},box)
                local badge=label(box,"");badge.Name="PlayerStatus";badge.TextSize=9;badge.Position=UDim2.fromOffset(4,3);badge.Size=UDim2.new(1,-8,0,12);badge.ZIndex=46
                cell={box=box,image=image,viewport=viewport,caption=caption,stroke=stroke,badge=badge};self.cells[slot]=cell
                keep(box.Activated:Connect(function()
                    local row=cell.item
                    if not row or (cfg.PlayerCards and row.remoteProtected) then return end
                    local name=tostring(row.name or row.id)
                    if cfg.Click then UI:closepopup();cfg.Click(name,row);UI:chime("on");return end
                    if cfg.Multi then self.selected[name]=not self.selected[name] or nil else self.selected=name end
                    self:refresh()
                    if cfg.Callback then cfg.Callback(self.selected) end
                    UI:RefreshCompact()
                    UI:chime("on")
                end))
                keep(box.MouseButton2Click:Connect(function()
                    local row=cell.item
                    if row and cfg.Context then
                        local mouse=game:GetService("UserInputService"):GetMouseLocation()
                        cfg.Context(tostring(row.name or row.id),row,mouse.X,mouse.Y,box)
                    end
                end))
            end
            cell.item=item;cell.box.Visible=item~=nil
            if item then
                local absolute=first+slot-2
                cell.box.Position=UDim2.fromOffset((absolute%columns)*(width+5),math.floor(absolute/columns)*rowHeight)
                cell.box.Size=UDim2.fromOffset(width,rowHeight-5)
                cell.caption.Text=tostring(item.label or item.name or "")
                if not cfg.PlayerCards then cell.caption.Text=text(cell.caption.Text) end
                cell.image.Image=type(item.image)=="string" and item.image or ""
                if cell.previewName~=item.name then
                    cell.previewName=item.name
                    cell.viewport:ClearAllChildren();cell.viewport.CurrentCamera=nil
                    cell.viewport.Visible=false;cell.image.Visible=true
                    if type(item.preview)=="function" then
                        local requested=item
                        task.spawn(function()
                            if not UI.alive or cell.item~=requested then return end
                            local ok,rendered=pcall(requested.preview,cell.viewport,requested)
                            if UI.alive and cell.item==requested and ok and rendered then
                                cell.viewport.Visible=true;cell.image.Visible=false
                            end
                        end)
                    end
                end
                local selected=cfg.Multi and self.selected[tostring(item.name)] or self.selected==tostring(item.name)
                cell.stroke.Color=(item.remoteListed or item.remoteProtected) and Color3.fromRGB(235,190,75) or item.blacklisted and Color3.fromRGB(255,75,85) or selected and UI.theme.accent or UI.theme.line
                cell.stroke.Thickness=(item.remoteListed or item.remoteProtected or item.blacklisted or selected) and 2 or 1
                cell.stroke.Transparency=0
                cell.badge.Visible=cfg.PlayerCards==true
                cell.badge.Text=(item.remoteListed or item.remoteProtected) and "protected" or item.blacklisted and "blacklist" or selected and "whitelist" or ""
                cell.badge.TextColor3=cell.stroke.Color
            end
        end
        for slot=capacity+1,#self.cells do self.cells[slot].box.Visible=false end
    end
    function gallery:setdata(data)
        self.data=data or {};self.filtered={}
        local query=search.Text:lower()
        for _,item in ipairs(self.data) do
            if query=="" or tostring(item.label or item.name):lower():find(query,1,true) then self.filtered[#self.filtered+1]=item end
        end
        self:refresh()
    end
    function gallery:set(value,silent)
        self.selected=cfg.Multi and (type(value)=="table" and table.clone(value) or {}) or value
        self:refresh();if not silent and cfg.Callback then cfg.Callback(self.selected) end
        UI:RefreshCompact()
    end
    function gallery:get() return self.selected end
    keep(search:GetPropertyChangedSignal("Text"):Connect(function() scroller.CanvasPosition=Vector2.zero;gallery:setdata(gallery.data) end))
    keep(scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function() gallery:refresh() end))
    keep(scroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() gallery:refresh() end))
    UI:hook(cfg.Flag,"table",function() return gallery.selected end,function(v) gallery:set(v) end)
    page.galleries[#page.galleries+1]=gallery
    gallery:setdata(gallery.data)
    return gallery
end

local function encode(value)
    local kind=typeof(value)
    if value==nil then return {__type="nil"} end
    if kind=="Color3" then return {__type="color",value.R,value.G,value.B} end
    if kind=="EnumItem" then return {__type="enum",enum=tostring(value.EnumType):gsub("Enum%.",""),name=value.Name} end
    if type(value)=="table" then local result={};for k,v in pairs(value) do result[k]=encode(v) end;return result end
    return value
end
local function decode(value)
    if type(value)~="table" then return value end
    if value.__type=="nil" then return nil end
    if value.__type=="color" then return Color3.new(value[1],value[2],value[3]) end
    if value.__type=="enum" then return Enum[value.enum][value.name] end
    local result={};for k,v in pairs(value) do result[k]=decode(v) end;return result
end
function UI:apply(data)
    self.quiet,self.configApplying=true,true
    local ok,err=pcall(function()
        for flag,value in pairs(data.flags or {}) do if self.pool[flag] then self.pool[flag].set(decode(value)) end end
    end)
    self.quiet,self.configApplying=false,false
    self:RefreshCompact()
    return ok,err
end
function UI:store(name)
    if not name:match("^[%w _%-]+$") then return nil end
    if not isfolder("Muse/Config") then makefolder("Muse/Config") end
    local data={version=1,flags={}}
    for flag,control in pairs(self.pool) do data.flags[flag]=encode(control.get()) end
    writefile("Muse/Config/"..name..".json",game:GetService("HttpService"):JSONEncode(data))
    return data
end
function UI:value(flag)
    local record=self.pool[flag]
    return record and record.get() or nil
end
function UI:active(...)
    for index=1,select("#",...) do
        local value=self:value(select(index,...))
        if value~=nil and value~=false and value~="None" and value~="none" and value~="Unknown" and value~="Off" and value~="off" then return true end
    end
    return false
end
function UI:SetSectionActivity(section,predicate,primaries)
    section.Activity=predicate;section.Primaries={}
    for _,flag in ipairs(primaries or {}) do section.Primaries[flag]=true end
end
function UI:Gate(flag,predicate) self.gates[flag]=predicate end
function UI:Dependency(flag,predicate) self.dependencies[flag]=predicate end
function UI:RefreshCompact()
    if not self.compactInstalled or self.refreshingCompact then return end
    self.refreshingCompact=true
    local function allowed(control,section)
        local gate=self.gates[control.Flag]
        local result=true
        if gate then result=gate()==true
        elseif section.Activity and not section.Primaries[control.Flag] then result=section.Activity()==true end
        local dependency=self.dependencies[control.Flag]
        return result and (not dependency or dependency()==true)
    end
    for _,meta in ipairs(self.rows) do
        local visible=false
        if #meta.Members==0 then visible=not meta.Section.Activity or meta.Section.Activity()==true end
        for _,control in ipairs(meta.Members) do
            local show=allowed(control,meta.Section)
            control.widget.Visible=show
            visible=visible or show
        end
        meta.Root.Size=meta.Size
        meta.Root.Visible=visible
    end
    for _,option in ipairs(self.options) do
        local owner=option.Owner
        local active=(owner.toggle and owner.toggle:get()==true) or (owner.keybind and owner.keybind:get()~=nil) or false
        local gate=owner.toggle and self.gates["options:"..tostring(owner.toggle.Flag)]
        if gate then active=gate()==true end
        if owner.optionActive~=active then owner.optionManual=nil;owner.optionActive=active end
        option.Root.Visible=active and owner.optionManual~=false
        owner.gear.Text=option.Root.Visible and "-" or "\u{2699}"
        owner.gear.TextColor3=active and self.theme.text or self.theme.dim
    end
    for _,section in ipairs(self.sections) do
        if section.Activity then
            for _,child in ipairs(section.items:GetChildren()) do
                if child:IsA("GuiObject") and not self.rowMap[child] then
                    local optionRoot=false
                    for _,option in ipairs(self.options) do if option.Root==child then optionRoot=true;break end end
                    if not optionRoot then child.Visible=section.Activity()==true end
                end
            end
        end
        if section.SectionGate then section.Root.Visible=section.SectionGate()==true end
    end
    for _,resize in ipairs(self.fits) do resize() end
    self.refreshingCompact=false
end

function UI:configs(page)
    local section=page:AddSection({Name="configs",Position="right"})
    local name=""
    local selected=""
    local choice=section:AddLabel("configs"):AddDropdown({Values={},Callback=function(v) selected=v end})
    section:AddLabel("config name"):AddTextInput({Callback=function(v) name=v end})
    local function refresh()
        local names={}
        if isfolder("Muse/Config") then
            for _,file in ipairs(listfiles("Muse/Config")) do local item=file:match("([^/\\]+)%.json$");if item then names[#names+1]=item end end
        end
        table.sort(names);choice:SetValues(names)
    end
    section:AddButton({Name="save",Callback=function() if self:store(name) then refresh();self:notify({content="config saved"}) end end})
    section:AddButton({Name="load",Callback=function()
        if selected~="" and selected:match("^[%w _%-]+$") then
            local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(readfile("Muse/Config/"..selected..".json")) end)
            if ok then local applied=self:apply(data);self:notify({content=applied and "config loaded" or "couldn't load config"}) end
        end
    end})
    section:AddButton({Name="delete",Callback=function()
        if selected~="" and selected:match("^[%w _%-]+$") then pcall(delfile,"Muse/Config/"..selected..".json");refresh() end
    end})
    section:AddButton({Name="refresh",Callback=refresh})
    refresh()
    return section
end
function UI:unload()
    if not self.alive then return end
    self.alive=false
    for _,connection in ipairs(self.conns) do connection:Disconnect() end
    for _,page in ipairs(self.tabs) do page.changed:Destroy() end
    self:closepopup()
    drawing._UNLOAD()
end
UI.notify=UI.notify
return UI

end
