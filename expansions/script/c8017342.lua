--Vibrazioni Minacciose
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cid.handcon)
	c:RegisterEffect(e2)
end
--ACTIVATE
function cid.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.setfilter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER)
end
-----------
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
	local g=Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(Card.IsFacedown,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_SZONE,0):Filter(Card.IsFacedown,nil)
	Duel.Destroy(g,REASON_EFFECT)
	local og=Duel.GetOperatedGroup():Filter(Card.IsType,nil,TYPE_PANDEMONIUM)
	local ct=og:GetCount()
	if ct>=1 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	local hg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(cid.thfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if ct>=2 and hg1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local shg1=hg1:Select(tp,1,1,nil)
		Duel.SendtoHand(shg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,shg1)
	end
	local rg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if ct>=3 and rg:GetCount()>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local srg=rg:Select(tp,1,1,nil)
		Duel.Destroy(srg,REASON_EFFECT)
	end
	local hg2=Duel.GetMatchingGroup(cid.setfilter,tp,LOCATION_DECK,0,nil)
	if ct==4 and hg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(cid.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local shg2=hg2:FilterSelect(tp,aux.PandSSetFilter(cid.setfilter,LOCATION_DECK),1,1,nil)
		aux.PandSSet(shg2,REASON_EFFECT,aux.GetOriginalPandemoniumType(shg2:GetFirst()))(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,shg2)
	end
end
--ACT IN HAND
function cid.doubtfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_PANDEMONIUM)
end
-------------
function cid.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0 and not Duel.IsExistingMatchingCard(cid.doubtfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end