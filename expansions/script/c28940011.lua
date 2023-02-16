--Gardrenial Cycle - Autumn
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	Gardrenial.EnableTrackers(c)
	c:SetUniqueOnField(1,0,id)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Gardrenial.NSPlant(tp) end)
	e1:SetTarget(ref.drtg)
	e1:SetOperation(ref.drop)
	c:RegisterEffect(e1)
	--Protect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(ref.uncon)
	e2:SetOperation(ref.unop)
	c:RegisterEffect(e2)
end

--Draw
function ref.tdfilter(c,rc)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (Gardrenial.Is(c) or c:IsRace(rc)) and c:IsAbleToDeck()
end
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and ref.tdfilter(chkc,RACE_INSECT) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil,RACE_INSECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil,RACE_INSECT)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function ref.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--Protet
function ref.uncon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsExistingMatchingCard(ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil,RACE_PLANT)
end
function ref.unop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,ref.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil,RACE_PLANT)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED+LOCATION_EXTRA,0)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTarget(ref.nultg)
		e1:SetValue(ref.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(re)
		Duel.RegisterEffect(e1,tp)
	end
end
function ref.efilter(e,re)
	return re==e:GetLabelObject()
end
function ref.nultg(e,c)
	return Gardrenial.Is(c) and c:IsFaceup()
end
