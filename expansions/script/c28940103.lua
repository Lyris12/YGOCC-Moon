--Clorix, Hollohom Regret
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
	e1:SetTarget(ref.edtg)
	e1:SetOperation(ref.edop)
	c:RegisterEffect(e1)
end

--Cycle
function ref.desfilter(c,ec) return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetColumnGroup():IsExists(Hollohom.Is,1,ec) end
function ref.desop(e,tp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,c) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,ref.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,c)
		Duel.HintSelection(g)
		Duel.Destroy(g,nil,REASON_EFFECT)
	end
end

--Add to ED
function ref.edfilter(c) return Hollohom.Is(c) and c:IsType(TYPE_PENDULUM) and not (c:IsCode(id) or c:IsForbidden()) end
function ref.edtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.edfilter,tp,LOCATION_DECK,0,1,nil) end
	local cat=0
	if Hollohom.FieldCheck(tp) then cat=cat+CATEGORY_TOGRAVE end
	e:SetCategory(cat)
end
function ref.edop(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,ref.edfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoExtraP(g,nil,REASON_EFFECT) and Hollohom.FieldCheck(tp) and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then Duel.SendtoGrave(g2,REASON_EFFECT) end
	end
end
