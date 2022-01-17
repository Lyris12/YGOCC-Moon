--Rifinitura Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsType(TYPE_SYNCHRO+TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(s.statfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.statfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.statfilter,tp,LOCATION_MZONE,0,tc)
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_SYNCHRO+TYPE_XYZ) and tc:IsAttribute(ATTRIBUTE_DARK) and #g>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE,1)
		local c=e:GetHandler()
		local val
		local lv=(tc:GetLevel()>0 or tc:IsStatus(STATUS_NO_LEVEL) or tc:IsHasEffect(EFFECT_GRANT_LEVEL)) and tc:GetLevel()
		local rk=tc:GetRank()>0 and tc:GetRank()
		if lv and rk and lv~=rk then
			local sel=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			if sel==0 then
				val=lv
			else
				val=rk
			end
		else
			if lv then
				val=lv
			else
				val=rk
			end
		end
		for sc in aux.Next(g) do 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(val)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RANK)
			sc:RegisterEffect(e2)
		end
	end
end
function s.lvtg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:GetFlagEffect(id)<=0
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()>0
end
function s.cfilter2(c,tp)
	return s.cfilter(c) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x27a) and c:IsType(TYPE_ST) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		if Duel.Draw(tp,d,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end