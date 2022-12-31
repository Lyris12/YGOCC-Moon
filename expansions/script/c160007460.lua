--Smokai - Oximonga
function c160007460.initial_effect(c)
	--battle destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(160007460,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c160007460.condition)
	e1:SetTarget(c160007460.target)
	e1:SetOperation(c160007460.operation)
	c:RegisterEffect(e1)
end
function c160007460.condition(e,tp,eg,ep,ev,re,r,rp)
	return  bit.band(e:GetHandler():GetReason(),REASON_BATTLE+REASON_EFFECT)~=0
end
function c160007460.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function c160007460.filter(c,e,tp)
	return c:IsCode(160007460) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c160007460.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	  Duel.Damage(1-tp,1000,REASON_EFFECT)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(c160007460.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(160007460,1)) then
		Duel.BreakEffect()
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		if ft>1 and g:GetCount()>1 and Duel.SelectYesNo(tp,aux.Stringid(160007460,1)) then
			Duel.SpecialSummonStep(g:GetNext(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.SpecialSummonComplete()
	end
end
