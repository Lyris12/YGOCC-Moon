--Mysterious Crab
function c53313912.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P: When a "Mysterious" monster on your side of the field is destroyed by battle or by your opponent's card effect: You can target 1 card on the field; destroy it.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c53313912.condition)
	e1:SetTarget(c53313912.target)
	e1:SetOperation(c53313912.activate)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1)
	--M: You can Tribute this card and 1 other Level 4 or lower "Mysterious" monster, then Special Summon 1 Level 7 or lower "Mysterious" monster from your Deck or GY. You can only use this effect of "Mysterious Crab" once per turn.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53313912)
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetTarget(c53313912.sptg)
	e2:SetOperation(c53313912.spop)
	c:RegisterEffect(e2)
end
function c53313912.spfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsSetCard(0xcf6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c53313912.cfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0xcf6) and c:IsReleasableByEffect()
end
function c53313912.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.CheckReleaseGroup(tp,c53313912.cfilter,1,c)
		and Duel.IsExistingMatchingCard(c53313912.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c53313912.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		local tc=Duel.SelectReleaseGroup(tp,c53313912.cfilter,1,1,c)
		tc:AddCard(c)
		if Duel.Release(tc,REASON_EFFECT)~=2 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c53313912.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if sg:GetCount()==0 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c53313912.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0xcf6) and ((c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)) or c:IsReason(REASON_BATTLE))
end
function c53313912.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.PandActCheck(e) and eg:IsExists(c53313912.filter,1,nil,tp)
end
function c53313912.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c53313912.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
