--Adaptive-Magician
function c249000637.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69610326,2))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,2490006371)
	e1:SetCondition(c249000637.spcon)
	e1:SetTarget(c249000637.sptg)
	e1:SetOperation(c249000637.spop)
	c:RegisterEffect(e1)
	--remove overlay replace
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32999573,0))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c249000637.rcon)
	e2:SetOperation(c249000637.rop)
	c:RegisterEffect(e2)
	--copy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetDescription(aux.Stringid(30312361,0))
	e3:SetCountLimit(2,2490006372)
	e3:SetCost(c249000637.cost)
	e3:SetTarget(c249000637.target2)
	e3:SetOperation(c249000637.operation2)
	c:RegisterEffect(e3)
end
c249000637.targetvalidi=true
function c249000637.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c249000637.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c249000637.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
function c249000637.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(249000637+ep)==0
		and bit.band(r,REASON_COST)~=0 and re:IsHasType(0x7e0)	and ev==1
end
function c249000637.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(249000637,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function c249000637.costfilter(c)
	return c:IsSetCard(0x1E1) and c:GetCode()~=249000637 and c:IsAbleToRemoveAsCost()
end
function c249000637.costfilter2(c,e)
	return c:IsSetCard(0x1E1) and c:GetCode()~=249000637 and not c:IsPublic()
end
function c249000637.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000637.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000637.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000637.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000637.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000637.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000637.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000637.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000637.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000637.tgfilter(c,e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not c:IsType(TYPE_EFFECT) then return false end
	if not global_card_effect_table[c] then return false end
	c249000637.targetvalidi=false
	for key,value in pairs(global_card_effect_table[c]) do
		local etemp=value
		if etemp and etemp:IsHasType(EFFECT_TYPE_IGNITION) and e:GetHandler():IsLocation(etemp:GetRange()) then 	
			local conf=etemp:GetCondition() 	
			local tef=etemp:GetTarget()
			local cof=etemp:GetCost()
			if not conf or conf(e,tp,eg,ep,ev,re,r,rp) then
				if not tef or tef(e,tp,eg,ep,ev,re,r,rp,0,nil) then
					c249000637.targetvalidi=true
					if not cof or cof(e,tp,eg,ep,ev,re,r,rp,0) then	return true end
				end
			end
		end
	end
	c249000637.targetvalidi=true
	return false
end
function c249000637.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if c249000637.targetvalidi==false then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(c249000637.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local tc=Duel.SelectMatchingCard(tp,c249000637.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,chk,chkc):GetFirst()
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
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsLocation(LOCATION_GRAVE) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
function c249000637.operation2(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end