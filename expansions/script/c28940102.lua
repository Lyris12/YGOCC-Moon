--Fixis, Hollowhom Madness
local ref,id=GetID()
xpcall(function() require("expansions/script/Hollohom") end,function() require("script/Hollohom") end)
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Hollohom.EnableUnion(c,ref.desop)
	--Add to ED
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(ref.edtg)
	e1:SetOperation(ref.edop)
	c:RegisterEffect(e1)
end

--Cycle
function ref.desfilter(c,ec) return c:GetColumnGroup():IsExists(Hollohom.Is,1,ec) end
function ref.desop(e,tp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,ref.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c)
		Duel.HintSelection(g)
		Duel.Destroy(g,nil,REASON_EFFECT)
	end
end

--Add to ED
function ref.edfilter(c) return Hollohom.Is(c) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
function ref.edtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(ref.edfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.edfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local cat=0
	if Hollohom.FieldCheck(tp) then cat=cat+CATEGORY_TOHAND end
	e:SetCategory(cat)
end
function ref.edop(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if not c:IsRelateToEffect(e) then return end
	if #g>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT) and Hollohom.FieldCheck(tp) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g2>0 and Duel.SendtoHand(g2,nil,REASON_EFFECT) then Duel.ConfirmCards(1-tp,g2) end
	end
end
