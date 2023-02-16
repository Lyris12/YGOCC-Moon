--Lurker in the Deptheavens
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Deptheaven.AddPendRestrict(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Deptheaven.Is,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	e1:SetCountLimit(1,{id,1})
	c:RegisterEffect(e1)
	--Set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(ref.settg)
	e2:SetOperation(ref.setop)
	c:RegisterEffect(e2)
	--GY Scale (BoM)
	local e3=Deptheaven.EnableGYScale(c,ref.postg,ref.posop)
	e3:SetProperty(Deptheaven.GYScaleProperty+EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_POSITION)
end

--Search
function ref.thfilter(c)
	if c:IsCode(id) or not c:IsAbleToHand() then return false end
	return (Deptheaven.Is(c) and c:IsType(TYPE_MONSTER))
		or c:IsCode(28940020)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end

--Self SS
function ref.setfilter(c) return Deptheaven.Is(c) and c:IsSSetable() end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and c:IsDiscardable(REASON_EFFECT) and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g) and g:GetFirst():IsType(TYPE_CONTINUOUS) and Deptheaven.LeftRightCheck(g:GetFirst())
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
	end
end

--BoM
function ref.posfilter(c) return c:IsFaceup() and c:IsCanTurnSet() end
function ref.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ref.posfilter(chkc) and chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(ref.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,ref.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function ref.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and ref.posfilter(tc) then
		Duel.BreakEffect()
		local pos=POS_FACEDOWN
		if tc:IsLocation(LOCATION_MZONE) then pos=POS_FACEDOWN_DEFENSE end
		Duel.ChangePosition(tc,pos)
		if tc:IsType(TYPE_SPELL+TYPE_TRAP) then Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0) end
	end
end
