--created & coded by Lyris
--F・HEROジュリーガル
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,cid.mfilter1,cid.mfilter2,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
end
function cid.mfilter1(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xf7a) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.mfilter2(c,fc,sub,mg,sg)
	return c:IsRace(RACE_WARRIOR) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf7a) and c:IsAbleToDeck() and not c:IsCode(id)
end
function cid.filter2(c)
	return c:IsFaceup() and not c:IsDisabled() or c:IsType(TYPE_TRAPMONSTER)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(cid.filter2,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.SelectTarget(tp,cid.filter1,tp,LOCATION_GRAVE,0,1,1,nil),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)==0
		or not tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then return end
	Duel.ShuffleDeck(tp)
	local g2=Duel.SelectMatchingCard(tp,cid.filter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	local c=e:GetHandler()
	local tc=g2:GetFirst()
	if tc then
		Duel.HintSelection(g2)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
