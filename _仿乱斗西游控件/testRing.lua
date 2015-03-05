local testRing = {}

function testRing:createRing()
	local widget = ui.binWidget("Ring_1.csb")
	
	local scrollLayer = widget:getChildByName("Ring")

	self.item_1 = scrollLayer:getChildByName("item_1")
	self.item_2 = scrollLayer:getChildByName("item_2")
	self.item_3 = scrollLayer:getChildByName("item_3")
	self.item_4 = scrollLayer:getChildByName("item_4")

	local midItem = self.item_1
	local leftItem = self.item_2
	local rightItem = self.item_4
	local backItem = self.item_3

	local midX = midItem:getPositionX()
	local leftX = leftItem:getPositionX()
	local rightX = rightItem:getPositionX()
	local backX = backItem:getPositionX()
	
	local midScale = midItem:getScale()
	local leftScale = leftItem:getScale()
	local rightScale = rightItem:getScale()
	local backScale = backItem:getScale()

	--local autoScrollDistance = 0
	local scrollBox = scrollLayer:getBoundingBox()
	local touchEventBox = midItem:getBoundingBox()
	
	local oneDistance = midX - leftX
	local touchBeganPos = 0
	local touchMovePos = 0
	local touchMoved = 0
	local touchMoveN = 0

	local function rebindItems(add)
		local midIdx, leftIdx, rightIdx, backIdx

		for i=1, 4 do
			if midItem == self["item_" .. i] then
				midIdx = i
				break
			end
		end
		if add then
			midIdx = midIdx%4+1
		else
			midIdx = midIdx-1
			if midIdx == 0 then
				midIdx = 4
			end
		end
		if midIdx == 1 then
			leftIdx = 2; backIdx = 3; rightIdx = 4;
		elseif midIdx == 2 then
			leftIdx = 3; backIdx = 4; rightIdx = 1;
		elseif midIdx == 3 then
			leftIdx = 4; backIdx = 1; rightIdx = 2;
		elseif midIdx == 4 then
			leftIdx = 1; backIdx = 2; rightIdx = 3;
		end
		
		midItem = self["item_" .. midIdx]
		leftItem = self["item_" .. leftIdx]
		rightItem = self["item_" .. rightIdx]
		backItem = self["item_" .. backIdx]

		midItem:setLocalZOrder(3)
		leftItem:setLocalZOrder(2)
		rightItem:setLocalZOrder(2)
		backItem:setLocalZOrder(1)
	end

	local function resetPos()
		if touchMoved > oneDistance/2 then
			rebindItems(true)
		elseif touchMoved < -oneDistance/2 then
			rebindItems()
		end
		midItem:setPositionX(midX)
		midItem:setScale(midScale)
		midItem:setLocalZOrder(4)

		leftItem:setPositionX(leftX)
		leftItem:setScale(leftScale)
		leftItem:setLocalZOrder(3)

		rightItem:setPositionX(rightX)
		rightItem:setScale(rightScale)
		rightItem:setLocalZOrder(2)

		backItem:setPositionX(backX)
		backItem:setScale(backScale)
		backItem:setLocalZOrder(1)

		for i=1, 4 do
			self["item_" .. i]:setColor(cc.c3b(255,255,255))
		end
	end
	

	local scale1 = midScale - leftScale
	local scale2 = leftScale - backScale 
	local function updatePos(xMoved)
		local absMoved = math.abs(xMoved)
		local percent = absMoved/oneDistance
		if xMoved >= 0 then
			midItem:setPositionX(midX+absMoved)
			midItem:setScale(midScale-scale1*percent)

			leftItem:setPositionX(leftX+absMoved)
			leftItem:setScale(leftScale+scale1*percent)

			rightItem:setPositionX(rightX-absMoved)
			rightItem:setScale(rightScale-scale2*percent)

			backItem:setPositionX(backX-absMoved)
			backItem:setScale(backScale+scale2*percent)

			midItem:setLocalZOrder(4)
			leftItem:setLocalZOrder(3)
			rightItem:setLocalZOrder(2)
			backItem:setLocalZOrder(1)
		elseif xMoved < 0 then
			midItem:setPositionX(midX-absMoved)
			midItem:setScale(midScale-scale1*percent)

			leftItem:setPositionX(leftX+absMoved)
			leftItem:setScale(leftScale-scale2*percent)

			rightItem:setPositionX(rightX-absMoved)
			rightItem:setScale(rightScale+scale1*percent)

			backItem:setPositionX(backX+absMoved)
			backItem:setScale(backScale+scale2*percent)

			midItem:setLocalZOrder(4)
			leftItem:setLocalZOrder(2)
			rightItem:setLocalZOrder(3)
			backItem:setLocalZOrder(1)
		end
	end

	local function midOnTouchBegan()
		midItem:setColor(cc.c3b(100,100,0))
	end
	local function midOnTouch()
		if midItem == self.item_1 then
			print("111111111")
		elseif midItem == self.item_2 then
			print("222222222")
		elseif midItem == self.item_3 then
			print("333333333")
		elseif midItem == self.item_4 then
			print("444444444")
		end
	end
	scrollLayer:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			touchMoveN = 0
			touchMoved = 0
			touchBeganPos = scrollLayer:convertToNodeSpace(scrollLayer:getTouchBeganPosition())

			if cc.rectContainsPoint(touchEventBox, touchBeganPos) then
				midOnTouchBegan()
			end
			touchBeganPos = touchBeganPos.x
		elseif eventType == ccui.TouchEventType.moved then
			touchMovePos = scrollLayer:getTouchMovePosition()
			if not cc.rectContainsPoint(scrollBox, touchMovePos) then
				return
			end
			touchMovePos = scrollLayer:convertToNodeSpace(touchMovePos).x
			touchMoved = touchMovePos-touchBeganPos-oneDistance*touchMoveN
			if touchMoved >= oneDistance then
				touchMoveN = touchMoveN + 1
				rebindItems(true)
			elseif touchMoved <= -oneDistance then
				touchMoveN = touchMoveN - 1
				rebindItems()
			end
			touchMoved = touchMovePos-touchBeganPos-oneDistance*touchMoveN
			updatePos(touchMoved)
        elseif eventType == ccui.TouchEventType.ended then
        	resetPos()
        	if cc.rectContainsPoint(touchEventBox, scrollLayer:convertToNodeSpace(scrollLayer:getTouchEndPosition())) then
				midOnTouch()
			end
			
        elseif eventType == ccui.TouchEventType.canceled then
        	resetPos()
        end
	end)

	return widget
end

function testRing:run()
	local scene = cc.Scene:create()
	local layer = cc.Layer:create()
	scene:addChild(layer)

	local ring = self:createRing()
	layer:addChild(ring)

	cc.Director:getInstance():runWithScene(scene)
end

return testRing