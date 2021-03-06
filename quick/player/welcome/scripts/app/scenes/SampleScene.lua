
local SampleScene = class("SampleScene", function()
    return display.newScene("SampleScene")
end)

function SampleScene:ctor()
    self.samples     = dofile(__G__QUICK_PATH__ .. "/samples/samples.lua")
    self.sampleIndex = 1
    local bg         = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    self:addChild(bg)

    self:createLogo()
    self:createPageView()
    self:createCopyright()
end

function SampleScene:createLogo()
    cc.ui.UIPushButton.new("LogoBanner.png")
        :onButtonClicked(function() 
            local evt = cc.EventCustom:new("WELCOME_APP")
            self:getEventDispatcher():dispatchEvent(evt)
        end)
        :align(display.LEFT_TOP, display.left + 20, display.top - 4)
        :addTo(self, 1)
end

function SampleScene:createCopyright()
    local label = ui.newTTFLabel({
        text = "Copyright 2012-2014 Chukong Technologies, Inc. Licensed under MIT License.",
        size = 14,
        color = cc.c3b(144, 144, 144),
        x = display.cx,
        y = display.bottom + 24,
        align = ui.TEXT_ALIGN_CENTER,
    })
    self:addChild(label)
end

function SampleScene:createPageView1()

    local originLeft  = display.left + 130
    local left        = originLeft
    local originTop   = display.top - 180
    local top         = originTop
    
    local vMargin     = 20
    local hMargin     = 30
    
    local imageWidth  = 200
    local imageHeight = 150

    local sampleCount = #self.samples
    local maxNum      = 12

    self.pageCount = math.ceil(sampleCount / maxNum)
    self.currentPageIndex = 1
    self.wallLayers = {}

    for pageCount = 1, self.pageCount do
        local wallLayer = display.newLayer()
        wallLayer:setTouchEnabled(false)
        wallLayer:setPosition(20, 25)
        wallLayer:setTag(1000 + pageCount)
        wallLayer:addTo(self)

        self.wallLayers[#self.wallLayers+1] = wallLayer

        top = originTop
        for i = 1, 3 do
            for j = 1, 4 do
                local sample = self.samples[self.sampleIndex]
                self.sampleIndex = self.sampleIndex + 1

                if sample ~= nil then
                    wallLayer:addChild(self:createDemoTitle(sample, left, top + 95))
                    wallLayer:addChild(self:createDemoDescription(sample ,left ,top + 75))
                    wallLayer:addChild(self:createDemoButton(sample, left, top))
                else
                    break
                end
                left = left + vMargin + imageWidth
            end

            left = originLeft
            top  = top - hMargin - imageHeight
        end
    end

    -- self:addChild(self.wallLayers[1])
    self:createBackButton()
    self:createLRButton()
    self:updateWall()
end

function SampleScene:createPageView()
    self.pageView = cc.ui.UIPageView.new{
        viewRect = cc.rect(50, 80, 860, 510),
        row = 3, column = 4,
        rowSpace = 20, columnSpace = 30}
        :onTouch(handler(self, self.gridViewListener))
        :addTo(self)

    local sampleCount = #self.samples

    for i=1,sampleCount do
        local sample = self.samples[i]
        local pageViewItem = self.pageView:newItem()

        pageViewItem:addChild(self:createDemoTitle(sample))
        pageViewItem:addChild(self:createDemoDescription(sample))
        pageViewItem:addChild(self:createDemoButton(sample))
        self.pageView:addItem(pageViewItem)
    end

    self.pageView:reload()
    self.pageCount = self.pageView:getPageCount()
    self:createBackButton()
    self:createLRButton()
end

function SampleScene:gridViewListener(event)
    if "pageChange" == event.name then
        self:updateArrow()
    end
end

-- helper

function SampleScene:createDemoTitle(sample, x, y)
    local label = ui.newTTFLabel({
        text = sample.title,
        align = ui.TEXT_ALIGNMENT_CENTER,
        color = cc.c3b(144,144,144),
        size = 14,
        font = "Monaco",
    })
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(100, 150)
    return label
end

function SampleScene:createDemoDescription(sample, x, y)
    local title =  sample.title
    local color = cc.c3b(50,144,144)
    if not cc.FileUtils:getInstance():isFileExist(__G__QUICK_PATH__ .. sample.path) then
        title = title .. " (unfinished)"
        color = cc.c3b(255,0,0)
    end

    local label = ui.newTTFLabel({
        text = title,
        align = ui.TEXT_ALIGNMENT_CENTER,
        color = color,
        size = 12,
    })
    label:setAnchorPoint(0.5, 0.5)
    label:setPosition(100, 140)
    return label
end

function SampleScene:createDemoButton(sample)
    function onButtonClick()
        local configPath = __G__QUICK_PATH__ .. sample.path .. "/scripts/config.lua"
        dofile(configPath)
        local args = {
            "-workdir",
            __G__QUICK_PATH__ .. sample.path,
            "-size",
            CONFIG_SCREEN_WIDTH.."x"..CONFIG_SCREEN_HEIGHT,
            "-" .. CONFIG_SCREEN_ORIENTATION,
        }
        local projectPath = __G__QUICK_PATH__ .. sample.path
        local commandline = "-workdir," .. projectPath .. ",-size," .. CONFIG_SCREEN_WIDTH.."x"..CONFIG_SCREEN_HEIGHT .. ",-" .. CONFIG_SCREEN_ORIENTATION .. ',-new'
    
        local evt = cc.EventCustom:new("WELCOME_OPEN_PROJECT_ARGS")
        evt:setDataString(commandline)
        self:getEventDispatcher():dispatchEvent(evt)
    end

    local demoImage = sample.image or "ListSamplesButton_zh.png"
    
    local button = cc.ui.UIPushButton.new(demoImage, {scale9 = true})
                        :onButtonClicked(onButtonClick)
                        :align(display.CENTER, 100, 65)
    return button
end

function SampleScene:createBackButton()
    cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
        :setButtonSize(100, 50)
        :setButtonLabel(cc.ui.UILabel.new({text = "Back", size = 20, color = display.COLOR_BLACK}))
        :pos(display.width - 80, 30)
        :addTo(self)
        :onButtonClicked(function()
            app:backToMainScene()
        end)
end

function SampleScene:createLRButton()
    cc.ui.UIPushButton.new("arrow_left.png", {scale9 = true})
        :setButtonSize(50, 50)
        :pos(30, display.cy)
        :addTo(self, 0, 100)
        :onButtonClicked(function()
            self:goLeftWall()
        end)

    cc.ui.UIPushButton.new("arrow_right.png", {scale9 = true})
        :setButtonSize(50, 50)
        :pos(display.width - 30, display.cy)
        :addTo(self, 0, 101)
        :onButtonClicked(function()
            self:goRightWall()
        end)

    self:updateArrow()
end

function SampleScene:updateArrow()
    local pageIdx = self.pageView:getCurPageIdx()
    local isLeftButtonVisible = true
    local isRightButtonVisible = true
    if 1 == self.pageCount then
        isLeftButtonVisible = false
        isRightButtonVisible = false
    else
        if 1 == pageIdx then
            isLeftButtonVisible = false
        elseif self.pageCount == pageIdx then
            isRightButtonVisible = false
        end
    end

    self:getChildByTag(100):setVisible(isLeftButtonVisible)
    self:getChildByTag(101):setVisible(isRightButtonVisible)
end

function SampleScene:goLeftWall()
    self.pageView:gotoPage(self.pageView:getCurPageIdx() - 1, true)
end

function SampleScene:goRightWall()
    self.pageView:gotoPage(self.pageView:getCurPageIdx() + 1, true)
end

function SampleScene:updateWall()
    for i,v in ipairs(self.wallLayers) do
        if i == self.currentPageIndex then
            v:setVisible(true)
            self:setLayerEnabled(v, true)
        else
            v:setVisible(false)
            self:setLayerEnabled(v, false)
        end
    end
end

-- helper

function SampleScene:setLayerEnabled(layer, isEnabled)
    for _,v in ipairs(layer:getChildren()) do
        v:setTouchEnabled(isEnabled)
    end
end

return SampleScene
