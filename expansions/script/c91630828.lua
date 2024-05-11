--[[
Lich-Lord's Effluvial Cloud
Nuvola Effluviale del Signore-Lich
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(COUNTER_EFFLUVIAL)
	aux.AddCodeList(c,CARD_LICH_LORD_PHYLACTERY)
	--You can only activate this card if a "Lich-Lord's Phylactery" is in your GY.
	c:Activation(false,false,aux.PhylacteryCondition)
	--[[Each time a Zombie monster(s) is Special Summoned from the GY, place 1 Effluvial Counter on this card.]]
	local SZChk=aux.AddThisCardInSZoneAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabelObject(SZChk)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--[[All monsters your opponent controls lose 100 ATK for each Effluvial Counter on this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--[[If this card leaves the field while it had 1 or more Effluvial Counters on it: You can activate this effect; send as many cards from the top of your Deck to the GY as possible,
	up to the number of Effluvial counters this card had on the field.]]
	local reg=aux.RegisterCountersBeforeLeavingField(c,COUNTER_EFFLUVIAL)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:HOPT()
	e3:SetFunctions(s.ddcon,nil,s.ddtg,s.ddop)
	e3:SetLabelObject(reg)
	c:RegisterEffect(e3)
	--[[If this card is in the GY, except during the turn it was sent there: You can banish this card from your GY; draw cards up to the number of "Lich-Lord" monsters you currently control +1,
	then shuffle 1 card from your hand into the Deck.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORY_DRAW|CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:HOPT()
	e4:SetFunctions(aux.exccon,aux.bfgcost,s.drawtg,s.drawop)
	c:RegisterEffect(e4)
end
--E1
function s.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsSummonLocation(LOCATION_GRAVE)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.AlreadyInRangeFilter(e,s.ctfilter),1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_EFFLUVIAL,1) then
		c:AddCounter(COUNTER_EFFLUVIAL,1)
	end
end

--E2
function s.atkval(e,c)
	return e:GetHandler():GetCounter(COUNTER_EFFLUVIAL)*-100
end

--E3
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetLabelObject():GetLabel()>0
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,val,REASON_EFFECT)
end

--E4
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_LICH_LORD)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.filter,p,LOCATION_MZONE,0,nil)+1
	local av={}
	for i=1,ct do
		if Duel.IsPlayerCanDraw(p,i) then
			table.insert(av,i)
		end
	end
	local n=Duel.AnnounceNumber(p,table.unpack(av))
	local drew=Duel.Draw(p,n,REASON_EFFECT)
	if drew~=0 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.ShuffleHand(p)
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end