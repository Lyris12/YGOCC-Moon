--[[
Curseflame Mastery
Maestria Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	c:Activation(false,true)
	--You can only control 1 "Curseflame Mastery".
	c:SetUniqueOnField(1,0,id)
	--You can target up to 3 "Curseflame" cards in your GY; shuffle those targets into the Deck, and if you do, place 1 Curseflame Counter on this card for each card shuffled into the Deck or Extra Deck by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--If this card is in your GY, except the turn it is sent there: You can target 1 other "Curseflame" card in your GY; shuffle both it and this card into the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(aux.exccon,nil,s.tdtg2,s.tdop2)
	c:RegisterEffect(e2)
	--If a "Curseflame" card(s) you control would be destroyed by battle or by an opponent's card effect, you can remove 1 Curseflame counter from anywhere on the field for each card that would be destroyed, instead (you must protect all your cards that would be destroyed, if you use this effect).
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
--E1
function s.tdfilter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsAbleToDeck()
end
function s.tdcheck(c,tp)
	return s.tdfilter(c) and c:IsControler(tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and c:IsCanAddCounter(COUNTER_CURSEFLAME,1) end
	local max=0
	for i=3,1,-1 do
		if c:IsCanAddCounter(COUNTER_CURSEFLAME,i) then
			max=i
			break
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,max,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,#g,tp,COUNTER_CURSEFLAME)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards():Filter(s.tdcheck,nil,tp)
	if #sg>0 then
		local ct=Duel.ShuffleIntoDeck(sg)
		local c=e:GetHandler()
		if ct>0 and c:IsRelateToChain() and c:IsCanAddCounter(COUNTER_CURSEFLAME,ct,true) then
			c:AddCounter(COUNTER_CURSEFLAME,ct,true)
		end
	end
end

--E2
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.tdcheck2(c)
	return c:IsRelateToChain() and c:IsAbleToDeck()
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc):Filter(s.tdcheck2,nil)
	if #g==2 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--E3
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
		and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.repfilter,nil,tp)
	if chk==0 then return ct>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,ct,REASON_EFFECT|REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:SetLabel(ct)
		return true
	else
		return false
	end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if not Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,ct,REASON_EFFECT|REASON_REPLACE) then return end
	Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,ct,REASON_EFFECT|REASON_REPLACE)
end