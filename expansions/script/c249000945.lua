--Cyber-Varia Knight
function c249000945.initial_effect(c)
	--set as spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(97)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2490009451)
	e1:SetCost(c249000945.cost)
	e1:SetTarget(c249000945.target1)
	e1:SetOperation(c249000945.operation1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE)
	e2:SetDescription(aux.Stringid(30312361,0))
	e2:SetCountLimit(1,2490009452)
	e2:SetCost(c249000945.cost)
	e2:SetTarget(c249000945.target2)
	e2:SetOperation(c249000945.operation2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,2490009453)
	e3:SetCondition(c249000945.condition1)
	e3:SetDescription(1066)
	e3:SetTarget(c249000945.target3)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c249000945.condition2)
	e4:SetTarget(c249000945.target4)
	c:RegisterEffect(e4)	
end
c249000945.targetvalidi=true
c249000945.targetvalidq=true
function c249000945.costfilter(c)
	return c:IsSetCard(0x1FD) and c:GetCode()~=249000945 and c:IsAbleToRemoveAsCost()
end
function c249000945.costfilter2(c,e)
	return c:IsSetCard(0x1FD) and c:GetCode()~=249000945 and not c:IsPublic()
end
function c249000945.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000945.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000945.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000945.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000945.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000945.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000945.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000945.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000945.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000945.stfilter(c,tp)
	if not c:IsType(TYPE_SPELL+TYPE_TRAP) then return false end
	if not c:IsAbleToDeck() then return false end
	if c:IsType(TYPE_SPELL+TYPE_FIELD) then return true end
	if not (c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)) then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	return true
end
function c249000945.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c249000945.stfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c249000945.stfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c249000945.stfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c249000945.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		if bit.band(tc:GetPreviousTypeOnField(),TYPE_FIELD)==TYPE_FIELD then
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
			end
			Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEDOWN,true)
		else
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end	
			Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(tc:GetPreviousTypeOnField())
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(code)
		c:RegisterEffect(e2)
		Duel.ConfirmCards(1-tp,c)
		local cid=c:CopyEffect(code,RESET_EVENT+0x1fe0000)
	end
end
function c249000945.tgfilter(c,e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not c:IsType(TYPE_EFFECT) then return false end
	if not global_card_effect_table[c] then return false end
	c249000945.targetvalidi=false
	for key,value in pairs(global_card_effect_table[c]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_IGNITION) and e:GetHandler():IsLocation(etemp:GetRange()) then 	
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					c249000945.targetvalidi=true
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then	return true end
				end
			end
		end
	end
	c249000945.targetvalidi=true
	return false
end
function c249000945.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if c249000945.targetvalidi==false then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(c249000945.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local tc=Duel.SelectMatchingCard(tp,c249000945.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	local t={}
	local desc_t = {}
	local p=1
	for key,value in pairs(global_card_effect_table[tc]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_IGNITION) and e:GetHandler():IsLocation(etemp:GetRange()) then
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then
						t[p]=etemp
						desc_t[p]=etemp:GetDescription()
						p=p+1
					end
				end
			end
		end
	end
	local index=1
	if p < 2 then return end
	if p > 2 then 
		index=Duel.SelectOption(tp,table.unpack(desc_t)) + 1
	end
	local te=t[index]
	Duel.ClearTargetCard()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabelObject(te)
	local co=te:GetCost()
	if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c249000945.operation2(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c249000945.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function c249000945.tgfilter2(c,e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not c:IsType(TYPE_EFFECT) then return false end
	c249000945.targetvalidq=false
	if not global_card_effect_table[c] then return false end
	for key,value in pairs(global_card_effect_table[c]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_QUICK_O) and e:GetHandler():IsLocation(etemp:GetRange()) and (etemp:GetCode()==EVENT_FREE_CHAIN or (etemp:GetCode()==EVENT_ATTACK_ANNOUNCE and Duel.GetAttacker()) or (etemp:GetCode()~=EVENT_ATTACK_ANNOUNCE and Duel.GetCurrentChain()>0)) then
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					c249000945.targetvalidq=true
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then	return true end
				end
			end
		end
	end
	c249000945.targetvalidq=true
	return false
end
function c249000945.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if c249000945.targetvalidq==false then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(c249000945.tgfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local tc=Duel.SelectMatchingCard(tp,c249000945.tgfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	local t={}
	local desc_t = {}
	local p=1
	for key,value in pairs(global_card_effect_table[tc]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_QUICK_O) and e:GetHandler():IsLocation(etemp:GetRange()) and (etemp:GetCode()==EVENT_FREE_CHAIN or (etemp:GetCode()==EVENT_ATTACK_ANNOUNCE and Duel.GetAttacker())) then
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then
						t[p]=etemp
						desc_t[p]=etemp:GetDescription()
						p=p+1
					end
				end
			end
		end
	end
	local index=1
	if p < 2 then return end
	if p > 2 then 
		index=Duel.SelectOption(tp,table.unpack(desc_t)) + 1
	end
	local te=t[index]
	Duel.ClearTargetCard()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabelObject(te)
	local co=te:GetCost()
	if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c249000945.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0
end
function c249000945.tgfilter3(c,e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not c:IsType(TYPE_EFFECT) then return false end
	c249000945.targetvalidq=false
	if not global_card_effect_table[c] then return false end
	for key,value in pairs(global_card_effect_table[c]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_QUICK_O) and e:GetHandler():IsLocation(etemp:GetRange()) and (etemp:GetCode()==EVENT_CHAINING and Duel.GetCurrentChain()>0) then
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					c249000945.targetvalidq=true
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then	return true end
				end
			end
		end
	end
	c249000945.targetvalidq=true
	return false
end
function c249000945.target4(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if c249000945.targetvalidq==false then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(c249000945.tgfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local tc=Duel.SelectMatchingCard(tp,c249000945.tgfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	local t={}
	local desc_t = {}
	local p=1
		for key,value in pairs(global_card_effect_table[tc]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_QUICK_O) and e:GetHandler():IsLocation(etemp:GetRange()) and (etemp:GetCode()==EVENT_CHAINING and Duel.GetCurrentChain()>0) then
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then
						t[p]=etemp
						desc_t[p]=etemp:GetDescription()
						p=p+1
					end
				end
			end
		end
	end
	local index=1
	if p < 2 then return end
	if p > 2 then 
		index=Duel.SelectOption(tp,table.unpack(desc_t)) + 1
	end
	local te=t[index]
	Duel.ClearTargetCard()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabelObject(te)
	local co=te:GetCost()
	if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end