-- drawing helper adapted from alex541-juju/juju/customapi.lua
-- original provenance retained; hosting does not transfer authorship.
    local env = getgenv and getgenv() or _G
    local cloneref = function(v) return v end
    local clonefunction = function(v) return v end
  
    -- // Variables
    local TextService = cloneref(game:GetService("TextService"))
    local HttpService = cloneref(game:GetService("HttpService"))
  
    local HttpGet = clonefunction(game.HttpGet)
    local GetTextBoundsAsync = clonefunction(TextService.GetTextBoundsAsync)
  
    local floor = clonefunction(math.floor)
    local atan2 = clonefunction(math.atan2)
    local clamp = clonefunction(math.clamp)
    local max = clonefunction(math.max)
    local huge = math.huge
    local pi = math.pi
  
    local string = {
        format = clonefunction(string.format),
        sub = clonefunction(string.sub)
    }
  
    local udim2New = clonefunction(UDim2.new)
    local fromOffset = clonefunction(UDim2.fromOffset)
  
    local vector2New = clonefunction(Vector2.new)
    local vectorZero = Vector2.zero
  
    local color3New = clonefunction(Color3.new)
  
    -- // Drawing2
    local Drawing2 = {}
  
    Drawing2.__CLASSES = {}
    Drawing2.__OBJECT_CACHE = {}
    Drawing2.__IMAGE_CACHE = {}
  
    Drawing2.Font = {
        Count = 0,
        Fonts = {},
        Enums = {}
    }
  
    function Drawing2.new(class)
        if not Drawing2.__CLASSES[class] then
            error(`Invalid argument #1, expected a valid Drawing2 type`, 2)
        end
  
        return Drawing2.__CLASSES[class].new()
    end
  
    function Drawing2.Font.new(name, font)
        assert(typeof(font) == "Font", "native font required")
        local id = Drawing2.Font.Count + 1
        Drawing2.Font.Count = id
        Drawing2.Font.Fonts[name] = id
        Drawing2.Font.Enums[id] = font
        local bounds = Drawing2.__TEXT_BOUND_PARAMS
        bounds.Text, bounds.Size, bounds.Font, bounds.Width = "Text", 12, font, huge
        GetTextBoundsAsync(TextService, bounds)
        return id
    end

    function Drawing2.CreateInstance(class, properties, children)
        local object = Instance.new(class)
  
        for property, value in properties or {} do
            object[property] = value
        end
  
        for idx, child in children or {} do
            child.Parent = object
        end
  
        return object
    end

    local __ROOT = Drawing2.CreateInstance("ScreenGui", {
        IgnoreGuiInset = true,
        DisplayOrder = 10,
        Name = HttpService:GenerateGUID(false),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui()
    })
  

    Drawing2.sgui = __ROOT
    
    function Drawing2._UNLOADCache()
        for idx, object in Drawing2.__OBJECT_CACHE do
            if rawget(object, "__OBJECT_EXISTS") then
                object:Remove()
            end
        end
    end
  
    local function UpdatePosition(object, from, to, thickness)
        local center = (from + to) / 2
        local offset = to - from
        local a = floor(thickness/2)
        object.Position = fromOffset(center.X + a, center.Y + a)
        object.Size = fromOffset(offset.Magnitude, thickness)
        object.Rotation = atan2(offset.Y, offset.X) * 180 / pi
    end
  
    Drawing2.__TEXT_BOUND_PARAMS = Drawing2.CreateInstance("GetTextBoundsParams", { Width = huge })
  
    --#region Line
    local Line = {}
  
    Drawing2.__CLASSES["Line"] = Line
  
    function Line.new()
        local LineObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                From = vectorZero,
                To = vectorZero,
                Thickness = 1,
                Transparency = 1,
                ZIndex = 0,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("Frame", {
                AnchorPoint = vector2New(0.5, 0.5),
                BackgroundColor3 = color3New(0, 0, 0),
                Position = udim2New(0, 0, 0, 0),
                Size = udim2New(0, 0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            })
        }, Line)
  
        table.insert(Drawing2.__OBJECT_CACHE, LineObject)
  
        return LineObject
    end
  
    function Line:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Line[property]
    end
  
    function Line:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties = self.__PROPERTIES
  
        Properties[property] = value
  
        if property == "Color" then
            self.__OBJECT.BackgroundColor3 = value
        elseif property == "From" then
            UpdatePosition(self.__OBJECT, Properties.From, Properties.To, Properties.Thickness)
        elseif property == "To" then
            UpdatePosition(self.__OBJECT, Properties.From, Properties.To, Properties.Thickness)
        elseif property == "Thickness" then
            local object = self.__OBJECT
            object.Size = fromOffset(object.AbsoluteSize.X, max(value, 1))
        elseif property == "Transparency" then
            self.__OBJECT.Transparency = clamp(1 - value, 0, 1)
        elseif property == "Visible" then
            self.__OBJECT.Visible = value
        elseif property == "ZIndex" then
            self.__OBJECT.ZIndex = value
        end
    end
  
    function Line:__iter()
        return next, self.__PROPERTIES
    end
  
    function Line:__tostring()
        return "Drawing2"
    end
  
    function Line:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Line:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Circle
    local Circle = {}
  
    Drawing2.__CLASSES["Circle"] = Circle
  
    function Circle.new()
        local CircleObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                Position = vector2New(0, 0),
                NumSides = 0,
                Radius = 0,
                Thickness = 1,
                Transparency = 1,
                ZIndex = 0,
                Filled = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("Frame", {
                AnchorPoint = vector2New(0.5, 0.5),
                BackgroundColor3 = color3New(0, 0, 0),
                Position = udim2New(0, 0, 0, 0),
                Size = udim2New(0, 0, 0, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("UICorner", {
                    Name = "_CORNER",
                    CornerRadius = UDim.new(1, 0)
                }),
                Drawing2.CreateInstance("UIStroke", {
                    Name = "_STROKE",
                    Color = color3New(0, 0, 0),
                    Thickness = 1
                })
            }),
        }, Circle)
  
        table.insert(Drawing2.__OBJECT_CACHE, CircleObject)
  
        return CircleObject
    end
  
    function Circle:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Circle[property]
    end
  
    function Circle:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties = self.__PROPERTIES
        local object = self.__OBJECT
  
        Properties[property] = value
  
        if property == "Color" then
            object.BackgroundColor3 = value
            object._STROKE.Color = value
        elseif property == "Filled" then
            object.BackgroundTransparency = value and 1 - Properties.Transparency or 1
        elseif property == "Position" then
            object.Position = fromOffset(value.X, value.Y)
        elseif property == "Radius" then
            self:__UPDATE_RADIUS()
        elseif property == "Thickness" then
            self:__UPDATE_RADIUS()
        elseif property == "Transparency" then
            object._STROKE.Transparency = clamp(1 - value, 0, 1)
            object.Transparency = Properties.Filled and clamp(1 - value, 0, 1) or object.Transparency
        elseif property == "Visible" then
            object.Visible = value
        elseif property == "ZIndex" then
            object.ZIndex = value
        end
    end
  
    function Circle:__iter()
        return next, self.__PROPERTIES
    end
  
    function Circle:__tostring()
        return "Drawing2"
    end
  
    function Circle:__UPDATE_RADIUS()
        local diameter = (self.__PROPERTIES.Radius * 2) - (self.__PROPERTIES.Thickness * 2)
        self.__OBJECT.Size = fromOffset(diameter, diameter)
    end
  
    function Circle:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Circle:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Text
    local Text = {}
  
    Drawing2.__CLASSES["Text"] = Text
  
    function Text.new()
        local TextObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(1, 1, 1),
                OutlineColor = color3New(0, 0, 0),
                Position = vector2New(0, 0),
                TextBounds = vector2New(0, 0),
                Text = "",
                Font = Drawing2.Font.Enums[1],
                Size = 13,
                Transparency = 1,
                ZIndex = 0,
                Center = false,
                Outline = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("TextLabel", {
                TextColor3 = color3New(1, 1, 1),
                Position = udim2New(0, 0, 0, 0),
                Size = udim2New(0, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                FontFace = Drawing2.Font.Enums[1],
                TextSize = 12,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("UIStroke", {
                    Name = "_STROKE",
                    Color = color3New(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Enabled = false,
                    Thickness = 1
                })
            })
        }, Text)
  
        table.insert(Drawing2.__OBJECT_CACHE, TextObject)
  
        return TextObject
    end
  
    function Text:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Text[property]
    end
  
    local type = type
  
    function Text:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        if value == "TextBounds" then
            error("Attempt to modify read-only property", 2)
        end
  
        local Properties = self.__PROPERTIES
  
        Properties[property] = value
  
        if property == "Color" then
            self.__OBJECT.TextColor3 = value
        elseif property == "Position" then
            self.__OBJECT.Position = fromOffset(value.X, value.Y)
        elseif property == "Size" then
            self.__OBJECT.TextSize = value
            self:_UPDATE_TEXT_BOUNDS()
        elseif property == "Text" then
            self.__OBJECT.Text = value
            self:_UPDATE_TEXT_BOUNDS()
        elseif property == "Font" then
            if type(value) == "string" then
                value = Drawing2.Font.Enums[Drawing2.Font.Fonts[value]]
            elseif type(value) == "number" then
                value = Drawing2.Font.Enums[value]
            end
  
            Properties.Font = value
  
            self.__OBJECT.FontFace = value
            self:_UPDATE_TEXT_BOUNDS()
        elseif property == "Outline" then
            self.__OBJECT.TextStrokeTransparency = value and 0 or 1
        elseif property == "OutlineColor" then
            self.__OBJECT._STROKE.Color = value
        elseif property == "Center" then
            self.__OBJECT.TextXAlignment = value and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        elseif property == "Transparency" then
            local value = clamp(1 - value, 0, 1)
            local object = self.__OBJECT
            object.Transparency = value
            object._STROKE.Transparency = value
        elseif property == "Visible" then
            self.__OBJECT.Visible = value
        elseif property == "ZIndex" then
            self.__OBJECT.ZIndex = value
        end
    end
  
    function Text:__iter()
        return next, self.__PROPERTIES
    end
  
    function Text:__tostring()
        return "Drawing2"
    end
  
    function Text:_UPDATE_TEXT_BOUNDS()
        local Properties = self.__PROPERTIES
        local TextBoundParams = Drawing2.__TEXT_BOUND_PARAMS
  
        TextBoundParams.Text = Properties.Text
        TextBoundParams.Size = Properties.Size
        TextBoundParams.Font = Properties.Font
        TextBoundParams.Width = huge
  
        Properties.TextBounds = GetTextBoundsAsync(TextService, Drawing2.__TEXT_BOUND_PARAMS)
    end
  
    function Text:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Text:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Square
    local Square = {}
  
    Drawing2.__CLASSES["Square"] = Square
  
    function Square.new()
        local SquareObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                Position = vector2New(0, 0),
                Size = vector2New(0, 0),
                Rounding = 0,
                Thickness = 0,
                Transparency = 1,
                ZIndex = 0,
                Filled = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("Frame", {
                Position = udim2New(0, 0, 0, 0),
                Size = udim2New(0, 0, 0, 0),
                BackgroundColor3 = color3New(0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("UIStroke", {
                    Name = "_STROKE",
                    Color = Color3.new(0, 0, 0),
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Thickness = 1
                })
            })
        }, Square)
  
        table.insert(Drawing2.__OBJECT_CACHE, SquareObject)
  
        return SquareObject
    end
  
    function Square:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Square[property]
    end
  
    function Square:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties = self.__PROPERTIES
  
        Properties[property] = value
  
        if property == "Color" then
            self.__OBJECT.BackgroundColor3 = value
            self.__OBJECT._STROKE.Color = value
        elseif property == "Position" then
            self:__UPDATE_SCALE()
        elseif property == "Size" then
            self:__UPDATE_SCALE()
        elseif property == "Thickness" then
            local stroke = self.__OBJECT._STROKE
            stroke.Thickness = value
            stroke.Enabled = not Properties.Filled
            self:__UPDATE_SCALE()
        elseif property == "Filled" then
            local object = self.__OBJECT
  
            object._STROKE.Enabled = not value
            object.BackgroundTransparency = value and 1 - Properties.Transparency or 1
        elseif property == "Transparency" then
            local value = -value + 1
            local object = self.__OBJECT
  
            object.Transparency = Properties.Filled and value or 1
            object._STROKE.Transparency = value
        elseif property == "Visible" then
            self.__OBJECT.Visible = value
        elseif property == "ZIndex" then
            self.__OBJECT.ZIndex = value
        end
    end
  
    function Square:__iter()
        return next, self.__PROPERTIES
    end
  
    function Square:__tostring()
        return "Drawing2"
    end
  
    function Square:__UPDATE_SCALE()
        local Properties = self.__PROPERTIES
  
        self.__OBJECT.Position = fromOffset(Properties.Position.X, Properties.Position.Y)
        self.__OBJECT.Size = fromOffset(Properties.Size.X, Properties.Size.Y)
    end
  
    function Square:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Square:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Image
    local Image = {}
  
    Drawing2.__CLASSES["Image"] = Image
  
    function Image.new()
        local ImageObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                Position = vector2New(0, 0),
                Size = vector2New(0, 0),
                Data = "",
                Uri = "",
                Thickness = 0,
                Transparency = 1,
                ZIndex = 0,
                Filled = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("ImageLabel", {
                Position = udim2New(0, 0, 0, 0),
                Size = udim2New(0, 0, 0, 0),
                BackgroundColor3 = color3New(0, 0, 0),
                Image = "",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("UICorner", {
                    Name = "_CORNER",
                    CornerRadius = UDim.new(0, 0)
                })
            })
        }, Image)
  
        table.insert(Drawing2.__OBJECT_CACHE, ImageObject)
  
        return ImageObject
    end
  
    function Image:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Image[property]
    end
  
    function Image:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties = self.__PROPERTIES
  
        Properties[property] = value
  
        if property == "Data" then
            self:__SET_IMAGE(value)
        elseif property == "Uri" then
            self:__SET_IMAGE(value, true)
        elseif property == "Rounding" then
            self.__OBJECT._CORNER.CornerRadius = UDim.new(0, value)
        elseif property == "Color" then
            self.__OBJECT.ImageColor3 = value
        elseif property == "Position" then
            self.__OBJECT.Position = fromOffset(value.X, value.Y)
        elseif property == "Size" then
            self.__OBJECT.Size = fromOffset(value.X, value.Y)
        elseif property == "Transparency" then
            self.__OBJECT.ImageTransparency = clamp(1 - value, 0, 1)
        elseif property == "Visible" then
            self.__OBJECT.Visible = value
        elseif property == "ZIndex" then
            self.__OBJECT.ZIndex = value
        end
    end
  
    function Image:__iter()
        return next, self.__PROPERTIES
    end
  
    function Image:__tostring()
        return "Drawing2"
    end
  
    function Image:__SET_IMAGE(data, isUri)
        task.spawn(function()
            if not self.__OBJECT_EXISTS then return end
            if isUri then
                data = HttpGet(game, data, true)
            end
  
            if not Drawing2.__IMAGE_CACHE[data] then
                if not isfolder("Muse") then makefolder("Muse") end
                if not isfolder("Muse/.ui") then makefolder("Muse/.ui") end
                local hash = 5381
                for index = 1, #data do hash = (hash * 33 + data:byte(index)) % 4294967296 end
                local TempPath = "Muse/.ui/" .. tostring(hash) .. ".png"
  
                writefile(TempPath, data)
                Drawing2.__IMAGE_CACHE[data] = getcustomasset(TempPath)
            end
  
            local object = self.__OBJECT
            if not self.__OBJECT_EXISTS then return end
  
            self.__PROPERTIES.Data = Drawing2.__IMAGE_CACHE[data]
            object.Image = Drawing2.__IMAGE_CACHE[data]
  
            object["Visible"] = true
            
            task.delay(0, function()
                object["Visible"] = self.__PROPERTIES["Visible"]
            end)
        end)
    end
  
    function Image:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Image:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Triangle
    local Triangle = {}
  
    Drawing2.__CLASSES["Triangle"] = Triangle
  
    function Triangle.new()
        local TriangleObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                PointA = vector2New(0, 0),
                PointB = vector2New(0, 0),
                PointC = vector2New(0, 0),
                Thickness = 1,
                Transparency = 1,
                ZIndex = 0,
                Filled = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("Frame", {
                Size = udim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("Frame", {
                    Name = "_A",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                }),
                Drawing2.CreateInstance("Frame", {
                    Name = "_B",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                }),
                Drawing2.CreateInstance("Frame", {
                    Name = "_C",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                })
            })
        }, Triangle)
  
        table.insert(Drawing2.__OBJECT_CACHE, TriangleObject)
  
        return TriangleObject
    end
  
    function Triangle:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Triangle[property]
    end
  
    function Triangle:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties, Object = self.__PROPERTIES, self.__OBJECT
  
        Properties[property] = value
  
        if property == "Color" then
            Object._A.BackgroundColor3 = value
            Object._B.BackgroundColor3 = value
            Object._C.BackgroundColor3 = value
        elseif property == "Transparency" then
            Object._A.BackgroundTransparency = 1 - values
            Object._B.BackgroundTransparency = 1 - values
            Object._C.BackgroundTransparency = 1 - values
        elseif property == "Thickness" then
            Object._A.BackgroundColor3 = fromOffset(Object._A.AbsoluteSize.X, max(value, 1));
            Object._B.BackgroundColor3 = fromOffset(Object._B.AbsoluteSize.X, max(value, 1));
            Object._C.BackgroundColor3 = fromOffset(Object._C.AbsoluteSize.X, max(value, 1));
        elseif property == "PointA" then
            self:__UPDATE_VERTICIES({
                { Object._A, Properties.PointA, Properties.PointB },
                { Object._C, Properties.PointC, Properties.PointA }
            })
        elseif property == "PointB" then
            self:__UPDATE_VERTICIES({
                { Object._A, Properties.PointA, Properties.PointB },
                { Object._B, Properties.PointB, Properties.PointC }
            })
        elseif property == "PointC" then
            self:__UPDATE_VERTICIES({
                { Object._B, Properties.PointB, Properties.PointC },
                { Object._C, Properties.PointC, Properties.PointA }
            })
        elseif property == "Visible" then
            Object.Visible = value
        elseif property == "ZIndex" then
            Object.ZIndex = value
        end
    end
  
    function Triangle:__iter()
        return next, self.__PROPERTIES
    end
  
    function Triangle:__tostring()
        return "Drawing2"
    end
  
    function Triangle:__UPDATE_VERTICIES(verticies)
        local thickness = self.__PROPERTIES.Thickness
  
        for idx, verticy in verticies do
            UpdatePosition(verticy[1], verticy[2], verticy[3], thickness)
        end
    end
  
    function Triangle:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Triangle:Destroy()
        self:Remove()
    end
    --#endregion
  
    --#region Quad
    local Quad = {}
  
    Drawing2.__CLASSES["Quad"] = Quad
  
    function Quad.new()
        local QuadObject = setmetatable({
            __OBJECT_EXISTS = true,
            __PROPERTIES = {
                Color = color3New(0, 0, 0),
                PointA = vector2New(0, 0),
                PointB = vector2New(0, 0),
                PointC = vector2New(0, 0),
                PointD = vector2New(0, 0),
                Thickness = 1,
                Transparency = 1,
                ZIndex = 0,
                Filled = false,
                Visible = false
            },
            __OBJECT = Drawing2.CreateInstance("Frame", {
                Size = udim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = 0,
                Visible = false,
                Parent = __ROOT
            }, {
                Drawing2.CreateInstance("Frame", {
                    Name = "_A",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                }),
                Drawing2.CreateInstance("Frame", {
                    Name = "_B",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                }),
                Drawing2.CreateInstance("Frame", {
                    Name = "_C",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                }),
                Drawing2.CreateInstance("Frame", {
                    Name = "_D",
                    Position = udim2New(0, 0, 0, 0),
                    Size = udim2New(0, 0, 0, 0),
                    AnchorPoint = vector2New(0.5, 0.5),
                    BackgroundColor3 = color3New(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 0
                })
            })
        }, Quad)
  
        table.insert(Drawing2.__OBJECT_CACHE, QuadObject)
  
        return QuadObject
    end
  
    function Quad:__index(property)
        local value = self.__PROPERTIES[property]
  
        return value or Quad[property]
    end
  
    function Quad:__newindex(property, value)
        if not __ROOT or not self.__OBJECT_EXISTS then
            return
        end
  
        local Properties, Object = self.__PROPERTIES, self.__OBJECT
  
        Properties[property] = value
  
        if property == "Color" then
            Object._A.BackgroundColor3 = value
            Object._B.BackgroundColor3 = value
            Object._C.BackgroundColor3 = value
            Object._D.BackgroundColor3 = value
        elseif property == "Transparency" then
            Object._A.BackgroundTransparency = 1 - value
            Object._B.BackgroundTransparency = 1 - value
            Object._C.BackgroundTransparency = 1 - value
            Object._D.BackgroundTransparency = 1 - value
        elseif property == "Thickness" then
            Object._A.BackgroundColor3 = fromOffset(Object._A.AbsoluteSize.X, max(value, 1));
            Object._B.BackgroundColor3 = fromOffset(Object._B.AbsoluteSize.X, max(value, 1));
            Object._C.BackgroundColor3 = fromOffset(Object._C.AbsoluteSize.X, max(value, 1));
            Object._D.BackgroundColor3 = fromOffset(Object._D.AbsoluteSize.X, max(value, 1));
        elseif property == "PointA" then
            self:__UPDATE_VERTICIES({
                { Object._A, Properties.PointA, Properties.PointB },
                { Object._D, Properties.PointD, Properties.PointA }
            })
        elseif property == "PointB" then
            self:__UPDATE_VERTICIES({
                { Object._A, Properties.PointA, Properties.PointB },
                { Object._B, Properties.PointB, Properties.PointC }
            })
        elseif property == "PointC" then
            self:__UPDATE_VERTICIES({
                { Object._B, Properties.PointB, Properties.PointC },
                { Object._C, Properties.PointC, Properties.PointD }
            })
        elseif property == "PointD" then
            self:__UPDATE_VERTICIES({
                { Object._C, Properties.PointC, Properties.PointD },
                { Object._D, Properties.PointD, Properties.PointA }
            })
        elseif property == "Visible" then
            Object.Visible = value
        elseif property == "ZIndex" then
            Object.ZIndex = value
        end
    end
  
    function Quad:__iter()
        return next, self.__PROPERTIES
    end
  
    function Quad:__tostring()
        return "Drawing2"
    end
  
    function Quad:__UPDATE_VERTICIES(verticies)
        local thickness = self.__PROPERTIES.Thickness
  
        for idx, verticy in verticies do
            UpdatePosition(verticy[1], verticy[2], verticy[3], thickness)
        end
    end
  
    function Quad:Remove()
        self.__OBJECT_EXISTS = false
        self.__OBJECT.Destroy(self.__OBJECT)
        table.remove(Drawing2.__OBJECT_CACHE, table.find(Drawing2.__OBJECT_CACHE, self))
    end
  
    function Quad:Destroy()
        self:Remove()
    end
  

  
    Drawing2.Font.new("A", Font.fromEnum(Enum.Font.GothamMedium))
  Drawing2.Font.new("B", Font.fromEnum(Enum.Font.GothamMedium))
  Drawing2.Font.new("C", Font.fromEnum(Enum.Font.GothamMedium))
    Drawing2["_UNLOAD"] = function()
        local old = __ROOT
        __ROOT = nil
        old:Destroy()
    end

  return Drawing2
  
